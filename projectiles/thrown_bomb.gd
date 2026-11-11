extends Area2D

const BOMB_TEXTURE = preload("res://assets/sprites/bomb.png")
## The source image is 412x500. This brings a normal bomb down to about 33 pixels.
const SPRITE_SCALE: float = 0.08

## Pixels per second along the ground. Height is faked by scaling the sprite.
var speed: float = 320
var direction: Vector2 = Vector2.RIGHT
## Seconds from release until the bomb reaches its landing point.
var flight_time: float = 0.7
var damage: float = 8
var blast_radius: float = 70
## 0 explodes on impact. Above 0, the bomb lands and waits, then explodes.
var fuse_time: float = 0.0
## Multiplier on the drawn bomb. The ability throw sets this above 1.
var visual_scale: float = 1.0
var attacking_group: String = "ally"

var _elapsed: float = 0.0
var _fusing: bool = false
var _exploded: bool = false

func _ready() -> void:
	var shape := $CollisionShape2D.shape.duplicate() as CircleShape2D
	shape.radius = 14.0 * visual_scale
	$CollisionShape2D.shape = shape
	_build_visuals()
	call_deferred("_check_initial_overlap")

func _physics_process(delta: float) -> void:
	if _fusing or _exploded: return
	_elapsed += delta
	var progress: float = clampf(_elapsed / flight_time, 0.0, 1.0)
	# Small at release, largest halfway through the throw, small again on landing.
	var arc: float = 0.45 + sin(progress * PI)
	$visual.scale = Vector2.ONE * visual_scale * arc
	global_position += speed * delta * direction
	if progress >= 1.0:
		if fuse_time > 0.0:
			_begin_fuse()
		else:
			_explode()

func _on_body_entered(body: Node2D) -> void:
	if _fusing or _exploded: return
	if body.is_in_group(attacking_group):
		# The heavy bomb finishes its throw and fuses. It does not blow up in the air.
		if fuse_time > 0.0: return
		_explode()
	elif not body.is_in_group("enemy") and not body.is_in_group("ally"):
		if fuse_time > 0.0:
			_begin_fuse()
		else:
			_explode()

func _check_initial_overlap() -> void:
	if fuse_time > 0.0 or _exploded: return
	for body in get_overlapping_bodies():
		_on_body_entered(body)

func _begin_fuse() -> void:
	if _fusing or _exploded: return
	_fusing = true
	$visual.scale = Vector2.ONE * visual_scale
	# Grow the danger circle out to the blast radius while the fuse burns.
	var tween_fuse := create_tween().set_parallel(true)
	tween_fuse.tween_property($warning, "scale", Vector2.ONE, fuse_time)
	tween_fuse.tween_property($warning, "modulate:a", 1.0, fuse_time)
	tween_fuse.chain().tween_callback(_explode)

func _explode() -> void:
	if _exploded or not is_inside_tree(): return
	_exploded = true
	_damage_in_radius()
	_spawn_blast()
	queue_free()

func _damage_in_radius() -> void:
	for body in get_tree().get_nodes_in_group(attacking_group):
		if not is_instance_valid(body): continue
		if body.get("state") == "dead": continue
		if global_position.distance_to(body.global_position) > blast_radius: continue
		if body.is_in_group("player"):
			# The ghost's take_damage signal always removes 1 heart. Skip them while they are inside a host.
			if PlayerInfo.possession_target: continue
			if fuse_time > 0.0:
				body.hurt(2)
			else:
				body.emit_signal("take_damage", damage)
		elif body.has_signal("take_damage"):
			body.emit_signal("take_damage", damage)

func _spawn_blast() -> void:
	var flash := Polygon2D.new()
	flash.polygon = _circle_points(blast_radius)
	flash.color = Color(1.0, 0.28, 0.05, 0.8) if fuse_time > 0.0 else Color(1.0, 0.5, 0.1, 0.7)
	flash.z_index = 6
	get_tree().current_scene.add_child(flash)
	flash.global_position = global_position
	var tween_fade := flash.create_tween()
	tween_fade.tween_property(flash, "modulate:a", 0.0, 0.25)
	tween_fade.tween_callback(flash.queue_free)

func _build_visuals() -> void:
	var visual := Node2D.new()
	visual.name = "visual"
	visual.z_index = 1
	visual.scale = Vector2.ONE * visual_scale * 0.45

	var sprite := Sprite2D.new()
	sprite.texture = BOMB_TEXTURE
	sprite.scale = Vector2(SPRITE_SCALE, SPRITE_SCALE)
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	visual.add_child(sprite)
	add_child(visual)

	var warning := Node2D.new()
	warning.name = "warning"
	warning.z_index = 0
	warning.scale = Vector2.ZERO
	warning.modulate = Color(1, 1, 1, 0)

	var points := _circle_points(blast_radius)
	var fill := Polygon2D.new()
	fill.polygon = points
	fill.color = Color(1.0, 0.45, 0.1, 0.28)
	warning.add_child(fill)

	var ring := Line2D.new()
	ring.points = points
	ring.closed = true
	ring.width = 4.0
	ring.default_color = Color(1.0, 0.55, 0.12, 0.95)
	ring.joint_mode = Line2D.LINE_JOINT_ROUND
	warning.add_child(ring)
	add_child(warning)

func _circle_points(radius: float) -> PackedVector2Array:
	var points := PackedVector2Array()
	for i in 32:
		points.append(Vector2.from_angle(TAU * float(i) / 32.0) * radius)
	return points
