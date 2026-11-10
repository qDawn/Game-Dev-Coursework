extends "res://projectiles/basic_bullet.gd"

const AOE_DOT = preload("uid://dyfqojoljvqhi")
var size = 1.0
var dot_damage = 0.5

func _on_expiry_timer_timeout() -> void:
	var area: Area2D = AOE_DOT.instantiate()
	area.scale *= size
	area.global_position = global_position
	area.attacking_group = attacking_group
	area.damage = dot_damage
	get_tree().root.call_deferred("add_child",area)
	super()
	
