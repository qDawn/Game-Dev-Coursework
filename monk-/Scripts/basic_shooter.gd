extends RigidBody2D

signal attack
signal take_damage
signal possession

const BULLET = preload("uid://dpygu43fwffkp")

var max_health: int = 100
var current_health: int = 100
var speed: int = 200
var min_range: int = 200
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

##This method describes how the enemy attacks
func _on_attack(direction: Vector2):
	if not attack_cooldown:
		var b: Area2D = BULLET.instantiate()
		b.global_position = global_position
		b.direction = direction
		b.speed = 400
		get_tree().root.add_child(b)
		
		attack_cooldown = true
		$attack_cooldown.start()

func _on_take_damage(num: int) -> void:
	current_health -= num
	if current_health <= 0: 
		state = 'dead'
		$possession_window.start()
		collision_layer = 2
		collision_mask = 2
		$sprite.self_modulate = Color(1,1,1,0.8)

func _on_attack_cooldown_timeout() -> void:
	attack_cooldown = false
	
func _on_possession_window_timeout() -> void:
	queue_free()

func _on_possession() -> void:
	$possession_window.stop()
	state = 'possessed'
