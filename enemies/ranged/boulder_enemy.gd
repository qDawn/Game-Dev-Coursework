extends "res://enemies/superclasses/enemy.gd"

const BOULDER = preload("res://projectiles/boulder.tscn")

var boulder_speed: float = 200
var knockback_speed: float = 500
var ability_speed: float = 300
var ability_knockback: float = 780
var ability_size: float = 1.65
var ability_damage: float = 14
var winding_up: bool = false
var held_scale: Vector2 = Vector2.ONE

func _ready() -> void:
	super()
	max_health = 40
	current_health = 40
	speed = 90
	min_range = 220
	attack_range = 480
	attack_cooldown = 2.4
	damage = 8
	ability_cooldown = 8
	held_scale = $weapon/spr.scale

func _process(delta: float) -> void:
	if state == "alive" and is_instance_valid(target) and not winding_up and not effects.has("stun"):
		if global_position.distance_to(target.global_position) <= attack_range and $ability_cooldown.is_stopped():
			_on_ability()
	super(delta)

func _on_attack(direction: Vector2) -> bool:
	if winding_up: return false
	if not super(direction): return false
	_launch(_aim_direction(direction), false)
	$weapon.visible = false
	return true

func _on_ability() -> bool:
	if winding_up or not super(): return false
	winding_up = true
	var tween_charge := create_tween()
	tween_charge.tween_property($weapon/spr, "scale", held_scale * ability_size, 0.55)
	tween_charge.tween_callback(_release_charged)
	return true

func aim(direction: Vector2):
	if winding_up: return
	super.aim(direction)

func _on_attack_cooldown_timeout() -> void:
	$weapon.visible = true

func _on_possession() -> void:
	super()
	ability_damage *= 1.5

func _aim_direction(direction: Vector2) -> Vector2:
	if state == "possessed":
		return global_position.direction_to(get_global_mouse_position())
	if is_instance_valid(target):
		return global_position.direction_to(target.global_position)
	return direction if direction.length_squared() > 0.0 else Vector2.RIGHT

func _launch(direction: Vector2, is_ability: bool) -> void:
	var launch_direction := direction.normalized() if direction.length_squared() > 0.0 else Vector2.RIGHT
	var size := ability_size if is_ability else 1.0
	var boulder: RigidBody2D = BOULDER.instantiate()
	boulder.direction = launch_direction
	boulder.damage = ability_damage if is_ability else damage
	boulder.launch_speed = ability_speed if is_ability else boulder_speed
	boulder.knockback_speed = ability_knockback if is_ability else knockback_speed
	boulder.boulder_size = size
	boulder.penetrating = is_ability
	boulder.attacking_group = "enemy" if state == "possessed" else "ally"
	boulder.thrower = self
	boulder.spawn_position = $weapon/spr.global_position + launch_direction * (28.0 * size + 24.0)
	get_tree().current_scene.add_child(boulder)

func _release_charged() -> void:
	winding_up = false
	$weapon/spr.scale = held_scale
	if state == "dead": return
	_launch(_aim_direction(Vector2.from_angle($weapon.rotation)), true)
