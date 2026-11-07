extends "res://projectiles/bullet.gd"

const ENEMY_BULLET = preload("uid://mq4hucp4nyfe")
var split_qty = 3

func _on_expiry_timer_timeout() -> void:
	for i in range(int(-split_qty/2.0),int((split_qty+1)/2.0)):
		var b: Area2D = ENEMY_BULLET.instantiate()
		b.global_position = global_position
		b.direction = direction.rotated(PI/12*i)
		b.damage = damage
		b.speed = 400
		b.attacking_group = attacking_group
		get_tree().current_scene.add_child(b)
	queue_free()
