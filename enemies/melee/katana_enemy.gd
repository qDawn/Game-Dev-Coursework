extends "res://enemies/superclasses/melee_enemy.gd"

var base_damage: float = 7
var base_speed: float = 230
var reset_ability: bool = false

func _ready() -> void:
	super()
	max_health = 22
	current_health = 22
	speed = 230
	min_range = 80
	attack_range = 150
	damage = base_damage
	swing_speed = 0.05
	attack_cooldown = 0.8
	ability_duration = 3
	ability_cooldown = 8

func _process(delta: float) -> void:
	super(delta)
	if attacking and not effects.has("silence"):
		for body: Node2D in $weapon_collision/melee_collision_area.get_overlapping_bodies():
			if body.is_in_group("ally") and is_in_group("enemy") or body.is_in_group("enemy") and is_in_group("ally"):
				if body.has_signal("take_effect"):
					body.emit_signal("take_effect","bleed",5)
				if not $ability_active.is_stopped():
					if body.state == "dead":
						reset_ability = true

		if reset_ability:
			$ability_active.start()
		elif not $ability_active.is_stopped():
			$ability_active.stop()
			_on_ability_active_timeout()

func _on_attack(direction: Vector2) -> bool:
	if not super(direction): return false
	reset_ability = false
	return true

func _on_ability() -> bool:
	if not super(): return false
	damage = base_damage * 2
	speed = base_speed * 1.5
	$weapon.scale = Vector2(2,2)
	$weapon_collision.scale = Vector2(2,2)
	return true

func _on_ability_active_timeout() -> void:
	super()
	damage = base_damage
	speed = base_speed
	$weapon.scale = Vector2(1,1)
	$weapon_collision.scale = Vector2(1,1)
	
func _on_possession() -> void:
	super()
	base_damage *= 1.5
	base_speed *= 1.5
