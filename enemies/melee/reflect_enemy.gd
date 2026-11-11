extends "res://enemies/superclasses/melee_enemy.gd"

var ability_range : int
const BASE_SPEED: float = 250


func _ready() -> void:
	super()
	max_health = 30
	current_health = 30
	speed = BASE_SPEED
	min_range = 60
	attack_range = 120
	ability_range = 500
	ability_cooldown = 8
	ability_duration = 3
	damage = 10
	swing_speed = 0.08
	attack_cooldown = 1

func _process(delta : float) -> void:
	super(delta)
	if state == 'alive':
		var distance: float = global_position.distance_to(target.global_position)
		if distance <= ability_range and $ability_cooldown.is_stopped():
			_on_ability()

func _on_ability() -> bool:
	if not super(): return false
	$reflect_area.visible = true
	$reflect_area.monitoring = true
	speed = BASE_SPEED*0.5
	return true

func _on_ability_active_timeout() -> void:
	super()
	$reflect_area.visible = false
	$reflect_area.monitoring = false
	speed = BASE_SPEED

func _on_reflect_area_area_entered(area: Area2D) -> void:
	if !area.is_in_group("reflected") and area.is_in_group("projectile"):
		area.damage *= 1.5
		area.scale *= 1.5
		area.direction = -area.direction
		area.attacking_group = "ally" if is_in_group("enemy") else "enemy"
		area.add_to_group("reflected")
