extends "res://enemies/melee/melee_enemy.gd"

func _ready() -> void:
	super()
	max_health = 22
	current_health = 22
	speed = 260
	min_range = 80
	attack_range = 150
	damage = 10
	swing_speed = 0.05

func _process(delta: float) -> void:
	super(delta)
	if attacking:
		for body in $weapon_collision/melee_collision_area.get_overlapping_bodies():
			body.emit_signal("take_effect","bleed",5)
