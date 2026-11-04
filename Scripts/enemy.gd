extends RigidBody2D

signal attack
signal ability
signal take_damage
signal possession

#health
var max_health: float = 10
var current_health: float = 10

#how fast it moves
var speed: int = 200
#how close it moves to the player
var min_range: int = 200
#how far it attacks from
var attack_range: int = 500
#how fast it can attack
var attack_speed: int = 10
#how much damage the enemy does
var damage: int = 5
#whether the attack is on cooldown
var attack_cooldown: bool = false
var ability_cooldown : bool = false
#valid states include: 'alive', 'dead', 'possessed'
var state: String = 'alive'
# Stores effects of the enemy. {name: duration}
var effects : Dictionary = {}
#whether the enemy is currently attacking
var attacking : bool = false

var can_move = true
func _ready() -> void:
	pass
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if state == 'alive': 
		var direction: Vector2 = global_position.direction_to(get_tree().get_first_node_in_group('player').global_position)
		var distance: float = global_position.distance_to(get_tree().get_first_node_in_group('player').global_position)
		
		#aim
		if !attacking:
			if direction.x < 0: $weapon.scale.y = -1
			else: $weapon.scale.y = 1
			$weapon.rotation = direction.angle()
		
		#if player is in attack range, attack
		if distance <= attack_range and not attack_cooldown and not effects.has("stun"):
			emit_signal('attack', direction)

	elif state == 'possessed':
		#aim
		if !attacking:
			var direction: Vector2 = global_position.direction_to(get_global_mouse_position())
			if direction.x < 0: $weapon.scale.y = -1
			else: $weapon.scale.y = 1
			$weapon.rotation = direction.angle()
		
	elif state == 'dead':
		#update the corpse timer bar with the time left to possess
		$corpse_timer.value = $possession_window.time_left

func _physics_process(delta: float) -> void:
	# Skip if enemy is dead or stunned in effects
	if !can_move: return
	if state == 'alive':
		
		var direction: Vector2 = global_position.direction_to(get_tree().get_first_node_in_group('player').global_position)
		var distance: float = global_position.distance_to(get_tree().get_first_node_in_group('player').global_position)

		# Don't move if approximately in range
		if 1 > abs(distance - min_range): return 
		#if the player is too far, move toward player
		if distance > min_range: 
			move_and_collide(direction*speed*delta)
		#if the player is too close, move away from player slowly
		if distance < min_range: 
			move_and_collide(-0.25*direction*speed*delta)
	elif state == 'possessed':
		#move in the direction the player moves + movement speed bonus
		move_and_collide(PlayerInfo.get_player_direction()*speed*delta*1.5)

	

##This method describes how the enemy attacks
func _on_attack(direction: Vector2):
	assert(false, "You need to implement how the enemy attacks!!")
	
func _on_ability():
	print("Tried to use ability but is not available :(")
	#assert(false, "You need to implement how the enemy uses abilities!!")
	
func _on_take_damage(num: int) -> void:
	current_health -= num
	if current_health <= 0: 
		if state == 'alive':
			state = 'dead'
			$possession_window.start()
			#set up and show the corpse timer bar
			$corpse_timer.max_value = $possession_window.wait_time
			$corpse_timer.value = $possession_window.wait_time
			$corpse_timer.show()
			collision_layer = 2
			collision_mask = 2
			$sprite.self_modulate = Color(1,1,1,0.8)
		elif state == 'possessed':
			#send signal to player that the possessed vessel has died.
			get_tree().get_first_node_in_group('player').emit_signal('cancel_possession')
			queue_free()
			
func _on_attack_cooldown_timeout() -> void:
	attack_cooldown = false
	
func _on_ability_cooldown_timeout() -> void:
	ability_cooldown = false
	
func _on_possession_window_timeout() -> void:
	queue_free()

func _on_possession() -> void:
	#stop the deletion from not being possessed.
	$possession_window.stop()
	#set the state to possessed.
	state = 'possessed'
	#reset the collision layers (so the possessed enemy can take damage again
	collision_layer = 1
	collision_mask = 1
	#make the sprite visible again
	$sprite.self_modulate = Color(1,1,1,1)
	#bleed tints modulate and leaves it on the corpse
	$sprite.modulate = Color.WHITE
	#recover hp + bonus hp
	max_health *= 1.5
	current_health = max_health
	#reset movement
	can_move = true
	effects.erase("stun")
	$stun_timer.stop()
	#damage bonus
	damage *= 1.5
	
	#start decaying
	$decay_timer.start()
	#remove from enemy group
	remove_from_group("enemy")
	#add to player group
	add_to_group("player")
	#hide the corpse timer bar
	$corpse_timer.hide()

func _on_decay_timer_timeout() -> void:
	#lose 5% health 
	current_health -= int(max_health*0.05)
	if current_health <= 0: 
		#send signal to player that the possessed vessel has died.
		get_tree().get_first_node_in_group('player').emit_signal('cancel_possession')
		queue_free()

#Bunch of code for bleed damage below
func apply_bleed() -> void:
	effects["bleed"] = 3.0
	$sprite.modulate = Color(1.0, 0.45, 0.45)
	if has_node("bleed_tick"):
		return
	var timer := Timer.new()
	timer.name = "bleed_tick"
	timer.wait_time = 1.0
	timer.timeout.connect(_on_bleed_tick)
	add_child(timer)
	timer.start()

func _on_bleed_tick() -> void:
	if not is_inside_tree() or state == "dead":
		_stop_bleed()
		return
	emit_signal("take_damage", 1)
	if not is_inside_tree() or state == "dead":
		if is_inside_tree():
			_stop_bleed()
		return
	effects["bleed"] = float(effects.get("bleed", 0.0)) - 1.0
	if effects["bleed"] <= 0.0:
		_stop_bleed()

func apply_stun(duration: float = 2.0) -> void:
	if state == "dead":
		return
	effects["stun"] = duration
	can_move = false
	$sprite.modulate = Color(0.55, 0.7, 1.0)
	$stun_timer.stop()
	$stun_timer.wait_time = duration
	$stun_timer.one_shot = true
	if not $stun_timer.timeout.is_connected(_on_stun_timer_timeout):
		$stun_timer.timeout.connect(_on_stun_timer_timeout)
	$stun_timer.start()

func _on_stun_timer_timeout() -> void:
	effects.erase("stun")
	if not is_inside_tree() or state == "dead":
		return
	can_move = true
	if effects.has("bleed"):
		$sprite.modulate = Color(1.0, 0.45, 0.45)
	else:
		$sprite.modulate = Color.WHITE

func _stop_bleed() -> void:
	effects.erase("bleed")
	if state != "dead" and is_inside_tree() and not effects.has("stun"):
		$sprite.modulate = Color.WHITE
	if has_node("bleed_tick"):
		$bleed_tick.queue_free()
