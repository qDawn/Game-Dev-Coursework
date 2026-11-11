extends "res://enemies/melee/melee_enemy.gd"

var stun_duration: float = 1
var winding_up: bool = false

func _ready() -> void:
	super()
	# Keep whatever position was set on weapon/spr in the editor.
	max_health = 80
	current_health = 80
	speed = 100
	min_range = 80
	attack_range = 150
	damage = 12
	swing_speed = 0.3
	# The bat recovers in 0.5 seconds. This swing is slower, so the pause is longer.
	attack_cooldown = 1.5
	_build_stun_circle()

func _process(delta: float) -> void:
	if state != "dead" and state != "possessed" and target:
		if global_position.distance_to(target.global_position) < $slam_area/CollisionShape2D.shape.radius and $ability_cooldown.is_stopped():
			_on_ability()
	super(delta)

func _on_ability() -> bool:
	if not super(): return false

	winding_up = true
	var warning: Node2D = $slam_area/warning
	warning.scale = Vector2.ZERO
	warning.modulate.a = 0.0

	# Raise the hammer while the stun circle grows to the slam radius.
	var tween_windup := create_tween().set_parallel(true)
	tween_windup.tween_property($weapon, "rotation_degrees", -90.0, 0.55)
	tween_windup.tween_property(warning, "scale", Vector2.ONE, 0.55)
	tween_windup.tween_property(warning, "modulate:a", 1.0, 0.55)
	tween_windup.chain().tween_callback(_slam_down)
	return true

func _on_attack(direction: Vector2) -> bool:
	if winding_up: return false
	return super(direction)

func aim(direction: Vector2, delta: float):
	if winding_up: return
	super.aim(direction, delta)

func _on_possession() -> void:
	super()
	stun_duration *= 1.5

func _slam_down() -> void:
	if state == "dead":
		winding_up = false
		_hide_stun_circle()
		return

	#slamming the hammer down
	var tween_slam: Tween = create_tween()
	tween_slam.tween_property($weapon, "rotation_degrees", 90.0, 0.14)
	tween_slam.tween_callback(_finish_slam)

	#flash the circle, then let it fade
	var warning: Node2D = $slam_area/warning
	var tween_circle: Tween = create_tween().set_parallel(true)
	tween_circle.tween_property(warning, "scale", Vector2(1.12, 1.12), 0.16)
	tween_circle.tween_property(warning, "modulate:a", 0.0, 0.16)
	tween_circle.chain().tween_callback(_hide_stun_circle)

	var attack_group := "ally" if state != "possessed" else "enemy"
	for body in $slam_area.get_overlapping_bodies():
		if body.is_in_group(attack_group):
			if body.has_signal("take_effect"):
				body.emit_signal("take_effect", "stun", stun_duration)
			body.emit_signal("take_damage", damage)

func _finish_slam() -> void:
	winding_up = false

func _build_stun_circle() -> void:
	var radius: float = $slam_area/CollisionShape2D.shape.radius
	var points := PackedVector2Array()
	for i in 32:
		points.append(Vector2.from_angle(TAU * float(i) / 32.0) * radius)

	var warning := Node2D.new()
	warning.name = "warning"
	warning.z_index = -1
	warning.position = $slam_area/CollisionShape2D.position
	warning.scale = Vector2.ZERO
	warning.modulate = Color(1, 1, 1, 0)

	var fill := Polygon2D.new()
	fill.polygon = points
	fill.color = Color(1.0, 0.86, 0.1, 0.35)
	warning.add_child(fill)

	var ring := Line2D.new()
	ring.points = points
	ring.closed = true
	ring.width = 5.0
	ring.default_color = Color(1.0, 0.95, 0.25, 1.0)
	ring.joint_mode = Line2D.LINE_JOINT_ROUND
	warning.add_child(ring)

	$slam_area.add_child(warning)

func _hide_stun_circle() -> void:
	if not is_instance_valid($slam_area/warning): return
	$slam_area/warning.scale = Vector2.ZERO
	$slam_area/warning.modulate.a = 0.0
