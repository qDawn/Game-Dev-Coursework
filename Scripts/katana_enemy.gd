extends "res://Scripts/melee_enemy.gd"

func _ready() -> void:
	super()
	max_health = 22
	current_health = 22
	speed = 260
	min_range = 80
	attack_range = 150
	damage = 10
	swing_speed = 0.05
