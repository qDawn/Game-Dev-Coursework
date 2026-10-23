extends RigidBody2D

signal take_damage

const BULLET = preload("uid://dpygu43fwffkp")

var max_health: int = 100
var current_health: int = 100
var speed: int = 100
var min_range: int = 200
var attack_cooldown: bool = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if current_health <= 0: 
		queue_free()
	
	#if the player exists
	var player: Node = get_tree().get_first_node_in_group('player')
	if player:
		var distance: float = global_position.distance_to(player.global_position)
		var direction: Vector2 = global_position.direction_to(player.global_position)
		#if the player is outside of range, move toward player
		if distance > min_range: 
			move_and_collide(direction*speed*delta)

		
		#attack player
		if not attack_cooldown:
			for i in range(-1,2):
				var b: Area2D = BULLET.instantiate()
				b.global_position = global_position
				b.direction = direction.rotated(PI/12*i)
				b.speed = 400
				get_tree().root.add_child(b)
			
			attack_cooldown = true
			$attack_cooldown.start()
		
func _on_take_damage(num: int) -> void:
	current_health -= num

func _on_attack_cooldown_timeout() -> void:
	attack_cooldown = false
