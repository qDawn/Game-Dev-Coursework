extends "res://enemies/superclasses/enemy.gd"


var roll_speed: float = 260
var drift: float = 0.5
var hit_cooldown: float = 0.5
var hit_zone_scale: float = 1.25
var spin_speed: float = 6.0


var roll_velocity: Vector2 = Vector2.ZERO
var hit_area: Area2D

func _ready() -> void:
	super()
	max_health = 30
	current_health = 30
	damage = 6

	#useless
	attack_range = 0
	$weapon.hide()

	#only the arena walls stop it
	collision_mask = 0
	set_collision_mask_value(8, true)
	#start rolling in a random direction
	roll_velocity = Vector2.from_angle(randf() * TAU) * roll_speed

	hit_area = Area2D.new()
	hit_area.collision_layer = 0
	hit_area.collision_mask = 1
	var zone := CollisionShape2D.new()
	zone.shape = $collision_shape.shape
	zone.position = $collision_shape.position
	hit_area.add_child(zone)
	hit_area.scale = Vector2.ONE * hit_zone_scale
	add_child(hit_area)

func _process(delta: float) -> void:
	super(delta)
	if state != 'dead':
		$sprite.rotation += spin_speed * delta

func _physics_process(delta: float) -> void:
	if state != 'alive':
		super(delta)
		return
	if effects.has("stun") or not target: return
	var angle_to_player: float = roll_velocity.angle_to(target.global_position - global_position)
	roll_velocity = roll_velocity.rotated(clampf(angle_to_player, -drift * delta, drift * delta))
	roll_velocity = roll_velocity.normalized() * roll_speed
	var motion: Vector2 = roll_velocity * delta
	if effects.has("slow"): motion *= 0.5
	var collision: KinematicCollision2D = move_and_collide(motion)
	if collision:
		roll_velocity = roll_velocity.bounce(collision.get_normal())
	_touch_damage()

func _touch_damage() -> void:
	if not $attack_cooldown.is_stopped(): return
	for body in hit_area.get_overlapping_bodies():
		if body != self and body.is_in_group("ally"):
			body.emit_signal("take_damage", damage)
			$attack_cooldown.start(hit_cooldown)
			return
