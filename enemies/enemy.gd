extends RigidBody2D

signal attack
signal ability
signal take_damage
signal take_effect
signal possession

#health
var max_health: float = 10
var current_health: float = 10

#how fast it moves
var speed: float = 200
#how close it moves to the player
var min_range: float = 200
#how far it attacks from
var attack_range: float = 500
#how fast it can attack
var attack_cooldown: float = 1
#how much damage the enemy does
var damage: float = 5
#whether the ability is on cooldown
var ability_cooldown : bool = false
#valid states include: 'alive', 'dead', 'possessed'
var state: String = 'alive'
# Stores effects of the enemy. Format: {name: duration}
var effects : Dictionary[String,int] = {}
#whether the enemy is currently attacking
var attacking : bool = false

func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if state != 'dead':
		var direction: Vector2
		var distance: float
		if state == 'possessed':
			direction = global_position.direction_to(get_global_mouse_position())
			aim(direction)
		else:
			direction = global_position.direction_to(get_tree().get_first_node_in_group('player').global_position)
			aim(direction)
			
			distance = global_position.distance_to(get_tree().get_first_node_in_group('player').global_position)
			#if player is in attack range, attack
			if distance <= attack_range and $attack_cooldown.is_stopped() and $hesitation_timer.is_stopped() and not effects.has("stun"):
				$exclamation.visible = true
				$hesitation_timer.start(randf_range(0.1,1))

		if not effects.is_empty() and $effect_timer.is_stopped():
			$effect_timer.start()
	else:
		#update the corpse timer bar with the time left to possess
		$corpse_timer.value = $possession_window.time_left

func _physics_process(delta: float) -> void:
	# Skip if enemy is dead or stunned in effects
	if effects.has("stun"): return
	var movement_vector: Vector2
	if state == 'alive':
		var direction: Vector2 = global_position.direction_to(get_tree().get_first_node_in_group('player').global_position)
		var distance: float = global_position.distance_to(get_tree().get_first_node_in_group('player').global_position)
		# Don't move if approximately in range
		if 1 > abs(distance - min_range): return 
		#if the player is too far, move toward player
		movement_vector = direction*speed*delta
		#if the player is too close, move away from player slowly
		if distance < min_range: movement_vector *= -0.25
	elif state == 'possessed':
		#move in the direction the player moves
		movement_vector = PlayerInfo.get_player_direction()*speed*delta

	if effects.has("slow"):
		movement_vector *= 0.75
	move_and_collide(movement_vector)

##This method describes how the enemy attacks
func _on_attack(direction: Vector2):
	if $attack_cooldown.is_stopped():
		$attack_cooldown.start(attack_cooldown)
		if effects.has("bleed"): _on_take_damage(damage)
#This method describes what the enemy does for its ability
func _on_ability(): print("Tried to use ability but is not available :(")

func _on_take_damage(num: float) -> void:
	current_health -= num
	if current_health <= 0: 
		if state == 'alive':
			state = 'dead'
			PlayerInfo.add_score(PlayerInfo.get_kill_points(scene_file_path.get_file().get_basename()))
			$possession_window.start()
			#set up and show the corpse timer bar
			$corpse_timer.max_value = $possession_window.wait_time
			$corpse_timer.value = $possession_window.wait_time
			$corpse_timer.show()
			collision_layer = 2
			collision_mask = 0
			$sprite.self_modulate = Color(1,1,1,0.8)
		elif state == 'possessed':
			#send signal to player that the possessed vessel has died.
			get_tree().get_first_node_in_group('player').emit_signal('cancel_possession')
			queue_free()
			
	#damage indication
	var tween_damage: Tween = get_tree().create_tween()
	tween_damage.tween_property($sprite,"self_modulate",Color(1,0,0),0.1)
	tween_damage.tween_property($sprite,"self_modulate",Color(1,1,1),0.1)
	
	var damage_ui: Label = preload("res://ui/damage_ui.tscn").instantiate()
	damage_ui.text = str(num)
	damage_ui.global_position = Vector2(global_position.x+20,global_position.y-20)
	get_tree().root.add_child(damage_ui)

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
	effects.clear()
	#damage bonus
	damage *= 1.5
	#speed bonus
	speed *= 1.5
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

func _on_effect_timer_timeout() -> void:
	for effect in effects:
		effects[effect] -= 0.5
		if effects[effect] <= 0: effects.erase(effect)

func _on_take_effect(effect: String, duration: int) -> void:
	if not effects.has(effect):
		effects[effect] = duration

#Method for aiming the weapon
func aim(direction: Vector2):
	if !attacking and not effects.has("stun"):
		if direction.x < 0: $weapon.scale.y = -1
		else: $weapon.scale.y = 1
		$weapon.rotation = direction.angle()

func _on_hesitation_timer_timeout() -> void:
	$exclamation.visible = false
	_on_attack(Vector2.from_angle($weapon.rotation))
