extends "res://enemies/superclasses/melee_enemy.gd"

func _ready() -> void:
	super()
	max_health = 3
	current_health = 3
	speed = 80
	min_range = 30
	attack_range = 70
	damage = 3
	attack_cooldown = 1.2
