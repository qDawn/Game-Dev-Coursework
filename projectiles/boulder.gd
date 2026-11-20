extends RigidBody2D

const BASE_RADIUS: float = 28.0
const BASE_SPRITE_SCALE: float = 0.22

var direction: Vector2 = Vector2.RIGHT
var launch_speed: float = 160
var damage: float = 8
var knockback_speed: float = 500
var boulder_size: float = 1.0
var attacking_group: String = "ally"
var spawn_position: Vector2 = Vector2.ZERO
var thrower: Node = null
## Ability boulders pass through a crowd instead of stopping on the first hit.
var penetrating: bool = false

var _hit: bool = false
var _hit_bodies: Array[Node] = []

func _ready() -> void:
	gravity_scale = 0
	can_sleep = false
	continuous_cd = CCD_MODE_CAST_RAY
	global_position = spawn_position
	if thrower is CollisionObject2D:
		add_collision_exception_with(thrower)

	var shape := $CollisionShape2D.shape.duplicate() as CircleShape2D
	shape.radius = BASE_RADIUS * boulder_size
	$CollisionShape2D.shape = shape
	$sprite.scale = Vector2.ONE * BASE_SPRITE_SCALE * boulder_size
	if penetrating:
		# Layer 3 is on the walls and on none of the characters, so the rock bounces off walls and rolls through the crowd.
		collision_layer = 4
		collision_mask = 4
		$hit_area.monitoring = true
		var hit_shape := $hit_area/CollisionShape2D.shape.duplicate() as CircleShape2D
		hit_shape.radius = BASE_RADIUS * boulder_size
		$hit_area/CollisionShape2D.shape = hit_shape
		$decay_timer.start(3.0)

	var launch_direction := direction.normalized() if direction.length_squared() > 0.0 else Vector2.RIGHT
	linear_velocity = launch_direction * launch_speed
	angular_velocity = 1.6 if launch_direction.x >= 0.0 else -1.6
	call_deferred("_check_initial_overlap")

func _check_initial_overlap() -> void:
	if not is_inside_tree(): return
	if penetrating:
		for body in $hit_area.get_overlapping_bodies():
			_on_hit_area_body_entered(body)
		return
	if _hit: return
	for body in get_colliding_bodies():
		_on_body_entered(body)

func _on_hit_area_body_entered(body: Node) -> void:
	if not penetrating or body == thrower or not body.is_in_group(attacking_group): return
	if body in _hit_bodies: return
	_hit_bodies.append(body)
	_shove(body)

func _on_body_entered(body: Node) -> void:
	if penetrating or _hit or not body.is_in_group(attacking_group): return
	_hit = true
	_shove(body)
	linear_velocity = Vector2.ZERO
	angular_velocity = 0
	$CollisionShape2D.set_deferred("disabled", true)
	if $decay_timer.time_left > 0.5:
		$decay_timer.start(0.5)

func _shove(body: Node) -> void:
	if body.has_method("apply_knockback"):
		var push_direction := linear_velocity
		if push_direction.length_squared() < 1.0:
			push_direction = direction
		body.apply_knockback(push_direction.normalized() * knockback_speed)
	if body.has_signal("take_damage"):
		body.emit_signal("take_damage", damage)

func _on_decay_timer_timeout() -> void:
	queue_free()
