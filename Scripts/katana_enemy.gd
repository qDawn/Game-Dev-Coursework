extends "res://Scripts/enemy.gd"

var already_hit: Array = []

func _ready() -> void:
	super()
	max_health = 22
	current_health = 22
	speed = 260
	min_range = 120
	attack_range = 300
	damage = 10
	# The bat's cooldown is 0.5 seconds. This is the recovery after the cut.
	$attack_cooldown.wait_time = 1.8

func _on_attack(direction: Vector2) -> void:
	if attack_cooldown:
		return
	attacking = true
	attack_cooldown = true
	already_hit.clear()

	var direction_angle: float = 180.0 * direction.angle() / PI
	var direction_multiplier := 1 if direction_angle >= -90.0 and direction_angle <= 90.0 else -1

	$weapon.rotation_degrees -= direction_multiplier * 100
	var tween_swing := create_tween()
	# The bat takes 0.1 seconds to swing. This one takes 0.05.
	tween_swing.tween_property($weapon, "rotation_degrees", direction_angle + direction_multiplier * 100, 0.05)
	tween_swing.tween_property(self, "attacking", false, 0)

	var tween_extend := create_tween()
	tween_extend.tween_property($weapon/spr, "position", Vector2(64, 0), 0.05)
	tween_extend.tween_property($weapon/spr, "position", Vector2(32, 0), 0)

	$weapon_collision.rotation_degrees = direction_angle
	$attack_cooldown.start()

func _process(delta: float) -> void:
	super(delta)
	if not attacking:
		return
	for body in $weapon_collision/melee_collision_area.get_overlapping_bodies():
		if body in already_hit or not _can_hit(body):
			continue
		already_hit.append(body)
		body.emit_signal("take_damage", damage)
		if is_instance_valid(body) and body.has_method("apply_bleed") and body.get("state") != "dead":
			body.apply_bleed()

func _can_hit(body: Node) -> bool:
	if state == "possessed":
		return body.is_in_group("enemy") and body.get("state") == "alive"
	return body.is_in_group("player")
