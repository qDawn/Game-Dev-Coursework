extends RigidBody2D

signal attack
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
#valid states include: 'alive', 'dead', 'possessed'
var state: String = 'alive'
#whether or not the enemy can move
var move : bool = true
# the player 
var player: Node2D

func _ready() -> void:
	player = get_tree().get_first_node_in_group('player')
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if state == 'alive': 
		var direction: Vector2 = global_position.direction_to(player.global_position)
		var distance: float = global_position.distance_to(player.global_position)
		
		#aim
		if direction.x < 0: $weapon.scale.y = -1
		else: $weapon.scale.y = 1
		$weapon.rotation = direction.angle()
		
		#if player is in attack range, attack
		if distance <= attack_range and not attack_cooldown:
			emit_signal('attack', direction)

	elif state == 'possessed':
		#move in the direction the player moves + movement speed bonus
		move_and_collide(PlayerInfo.get_player_direction()*speed*delta*1.5)
		#aim
		var direction: Vector2 = global_position.direction_to(get_global_mouse_position())
		if direction.x < 0: $weapon.scale.y = -1
		else: $weapon.scale.y = 1
		$weapon.rotation = direction.angle()
		
	elif state == 'dead':
		#update the corpse timer bar with the time left to possess
		$corpse_timer.value = $possession_window.time_left

func _physics_process(delta: float) -> void:
	# Skip if enemy is dead or cannot move
	if state != 'alive' or !move:
		return
		
	var direction: Vector2 = global_position.direction_to(player.global_position)
	var distance: float = global_position.distance_to(player.global_position)

	# Don't move if approximately in range
	if 1 > abs(distance - min_range):
		return 
	#if the player is too far, move toward player
	if distance > min_range: 
		move_and_collide(direction*speed*delta)
	#if the player is too close, move away from player slowly
	if distance < min_range: 
		move_and_collide(-0.25*direction*speed*delta)
		
	
		
			
##This method describes how the enemy attacks
func _on_attack(direction: Vector2):
	assert(false, "You need to implement how the enemy attacks!!")

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
			player.emit_signal('cancel_possession')
			queue_free()
			
func _on_attack_cooldown_timeout() -> void:
	attack_cooldown = false
	
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
	#recover hp + bonus hp
	max_health *= 1.5
	current_health = max_health
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
		player.emit_signal('cancel_possession')
		queue_free()
