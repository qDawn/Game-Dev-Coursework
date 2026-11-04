extends "res://Scripts/enemy.gd"

var already_hit: Array = []
var slamming: bool = false
var slam_radius: float = 180.0
var ring_alpha: float = 0.0
var ring_fading: bool = false
var hammer_rest: Vector2

func _ready() -> void:
	super()
	# Keep whatever position was set on weapon/spr in the editor.
	hammer_rest = $weapon/spr.position
	max_health = 80
	current_health = 80
	speed = 100
	min_range = 130
	attack_range = 250
	damage = 12
	# The bat recovers in 0.5 seconds. This swing is slower, so the pause is longer.
	$attack_cooldown.wait_time = 1.7
	$ability_cooldown.wait_time = 7.0
	$ability_cooldown.one_shot = true
	$slam_area/CollisionShape2D.shape.radius = slam_radius

func _process(delta: float) -> void:
	if state == "alive" and not ability_cooldown and not attacking and not effects.has("stun"):
		var player := get_tree().get_first_node_in_group("player")
		if player and global_position.distance_to(player.global_position) <= slam_radius:
			_on_ability()
	super(delta)
	if attacking and not slamming:
		for body in $weapon_collision/melee_collision_area.get_overlapping_bodies():
			if body in already_hit or not _can_hit(body):
				continue
			already_hit.append(body)
			body.emit_signal("take_damage", damage)
	if ring_fading:
		ring_alpha = max(ring_alpha - delta * 1.4, 0.0)
		if ring_alpha == 0.0:
			ring_fading = false
	if ring_alpha > 0.0:
		queue_redraw()

func _draw() -> void:
	if ring_alpha <= 0.0:
		return
	draw_arc(Vector2.ZERO, slam_radius, 0, TAU, 48, Color(1, 0.78, 0.15, ring_alpha), 6.0)

func _on_attack(direction: Vector2) -> void:
	if attack_cooldown or slamming or effects.has("stun"):
		return
	attacking = true
	attack_cooldown = true
	already_hit.clear()

	var direction_angle: float = 180.0 * direction.angle() / PI
	var direction_multiplier := 1 if direction_angle >= -90.0 and direction_angle <= 90.0 else -1

	$weapon.rotation_degrees -= direction_multiplier * 70
	var tween_swing := create_tween()
	# The bat completes a swing in 0.1 seconds. This one takes 0.45.
	tween_swing.tween_property($weapon, "rotation_degrees", direction_angle + direction_multiplier * 70, 0.45)
	tween_swing.tween_property(self, "attacking", false, 0)

	var tween_extend := create_tween()
	tween_extend.tween_property($weapon/spr, "position", hammer_rest + Vector2(36, 0), 0.45)
	tween_extend.tween_property($weapon/spr, "position", hammer_rest, 0)

	$weapon_collision.rotation_degrees = direction_angle
	$attack_cooldown.start()

func _on_ability() -> void:
	if ability_cooldown or slamming or attacking or effects.has("stun") or state == "dead":
		return
	ability_cooldown = true
	slamming = true
	attacking = true
	attack_cooldown = true
	can_move = false
	ring_alpha = 0.75
	ring_fading = false
	queue_redraw()
	$ability_cooldown.start()

	# Raise the hammer, then the impact callback brings it down.
	var windup := create_tween()
	windup.tween_property($weapon, "rotation_degrees", -90.0, 0.55)
	windup.tween_callback(_slam_down)

func _slam_down() -> void:
	if not is_inside_tree() or state == "dead":
		_finish_slam()
		return
	var slam := create_tween()
	slam.tween_property($weapon, "rotation_degrees", 90.0, 0.14)
	slam.tween_callback(_slam_impact)

func _slam_impact() -> void:
	if not is_inside_tree() or state == "dead":
		_finish_slam()
		return
	ring_alpha = 1.0
	ring_fading = true
	var attack_group := "player" if state != "possessed" else "enemy"
	for body in $slam_area.get_overlapping_bodies():
		if body == self or not body.is_in_group(attack_group):
			continue
		if attack_group == "enemy" and body.get("state") != "alive":
			continue
		if body.has_method("apply_stun"):
			body.apply_stun(2.0)
	_finish_slam()

func _finish_slam() -> void:
	slamming = false
	attacking = false
	ring_fading = true
	if not is_inside_tree() or state == "dead" or effects.has("stun"):
		return
	can_move = true
	$weapon/spr.position = hammer_rest
	$attack_cooldown.start()

func _can_hit(body: Node) -> bool:
	if state == "possessed":
		return body.is_in_group("enemy") and body.get("state") == "alive"
	return body.is_in_group("player")
