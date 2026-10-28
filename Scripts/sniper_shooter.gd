extends RigidBody2D

signal attack
signal take_damage
signal possession

const ENEMY_BULLET = preload("uid://dpygu43fwffkp")

#health
const max_health: float = 30
@export var current_health: float = 30

#how fast it moves
@export var speed: int = 200
#how close it gets to the player
@export var min_range: int = 500
#how fast it can attack
@export var attack_speed: int = 10
#how fast its projectiles move
@export var bullet_speed: int = 1000
#how much damage the projectiles do
@export var bullet_damage: int = 10
#whether the attack is on cooldown
var attack_cooldown: bool = false

#valid states include: 'alive', 'dead', 'possessed'
var state: String = 'alive'

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if state == 'alive': 
		#check that the player exists
		var player: Node = get_tree().get_first_node_in_group('player')
		if player:
			var distance: float = global_position.distance_to(player.global_position)
			var direction: Vector2 = global_position.direction_to(player.global_position)
			#if the player is outside of range, move toward player
			if distance > min_range: move_and_collide(direction*speed*delta)
			#attack player
			emit_signal('attack', direction)
	elif state == 'possessed':
		move_and_collide(PlayerInfo.get_player_direction()*speed*delta)
	elif state == 'dead':
		#update the corpse timer bar with the time left to possess
		$corpse_timer.value = $possession_window.time_left

##This method describes how the enemy attacks
func _on_attack(direction: Vector2):
	if not attack_cooldown:
		var b: Area2D = ENEMY_BULLET.instantiate()
		b.global_position = global_position
		b.direction = direction
		b.damage = bullet_damage
		b.speed = bullet_speed
		if state == 'possessed': b.remove_from_group("enemy_bullet"); b.add_to_group("player_bullet")
		get_tree().root.add_child(b)
		attack_cooldown = true
		$attack_cooldown.start()

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
	#recover hp
	current_health = max_health
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
