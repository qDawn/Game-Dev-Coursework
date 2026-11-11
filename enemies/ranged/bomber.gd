extends "res://enemies/enemy.gd"

const THROWN_BOMB = preload("res://projectiles/thrown_bomb.tscn")
const BOMB_TEXTURE = preload("res://assets/sprites/bomb.png")

var bomb_speed: float = 320
var blast_radius: float = 70
var ability_damage: float = 32
var ability_blast_radius: float = 160
var ability_scale: float = 1.8
var ability_fuse: float = 1.0

func _ready() -> void:
	super()
	max_health = 35
	current_health = 35
	speed = 150
	min_range = 260
	attack_range = 420
	attack_cooldown = 1.6
	damage = 8
	ability_cooldown = 8
	$weapon/spr.visible = false
	_build_held_bomb()

func _process(delta: float) -> void:
	if state == "alive" and is_instance_valid(target) and not effects.has("stun") and not effects.has("silence"):
		if global_position.distance_to(target.global_position) <= attack_range and $ability_cooldown.is_stopped():
			_on_ability()
	super(delta)

func _on_attack(direction: Vector2) -> bool:
	if not super(direction): return false
	_throw_bomb(_aim_point(direction), false)
	return true

func _on_ability() -> bool:
	if not super(): return false
	_throw_bomb(_aim_point(Vector2.from_angle($weapon.rotation)), true)
	return true

func _on_possession() -> void:
	super()
	ability_damage *= 1.5

func _aim_point(direction: Vector2) -> Vector2:
	if state == "possessed":
		return get_global_mouse_position()
	if is_instance_valid(target):
		return target.global_position
	return global_position + direction * 240

func _throw_bomb(aim_point: Vector2, is_ability: bool) -> void:
	var origin: Vector2 = $weapon/spr/origin.global_position
	var to_point: Vector2 = aim_point - origin
	var distance: float = to_point.length()
	var throw_direction: Vector2 = to_point / distance if distance > 8.0 else Vector2.from_angle($weapon.rotation)

	var bomb: Area2D = THROWN_BOMB.instantiate()
	bomb.global_position = origin
	bomb.direction = throw_direction
	bomb.speed = bomb_speed
	# Flight time is distance/speed, so the arc finishes as the bomb arrives.
	bomb.flight_time = clampf(distance / bomb_speed, 0.4, 1.15)
	bomb.attacking_group = "enemy" if state == "possessed" else "ally"
	if is_ability:
		bomb.damage = ability_damage
		bomb.blast_radius = ability_blast_radius
		bomb.fuse_time = ability_fuse
		bomb.visual_scale = ability_scale
	else:
		bomb.damage = damage
		bomb.blast_radius = blast_radius
		bomb.fuse_time = 0.0
		bomb.visual_scale = 1.0
	if state != "possessed":
		bomb.add_to_group("enemy_bullet")
	get_tree().current_scene.add_child(bomb)

func _build_held_bomb() -> void:
	var held := Sprite2D.new()
	held.name = "held_bomb"
	held.texture = BOMB_TEXTURE
	held.position = Vector2(36, 0)
	held.scale = Vector2(0.08, 0.08)
	held.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	$weapon.add_child(held)
