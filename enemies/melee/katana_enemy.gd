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
	attack_cooldown = 0.8

func _process(delta: float) -> void:
	super(delta)
	if attacking:
		for body in $weapon_collision/melee_collision_area.get_overlapping_bodies():
			if not effects.has("silence"):
				if body.is_in_group("player") and not state == "possessed" or body.is_in_group("enemy") and state == "possessed":
					body.emit_signal("take_effect","bleed",8)
