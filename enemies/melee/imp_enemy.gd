extends "res://enemies/superclasses/melee_enemy.gd"

func _ready() -> void:
	super()
	max_health = 8
	current_health = 8
	speed = 230
	min_range = 30
	attack_range = 70
	damage = 3
	attack_cooldown = 1.2
