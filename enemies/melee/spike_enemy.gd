extends "res://enemies/superclasses/enemy.gd"

var roll_speed: float = 260
var possessed_speed_bonus: float = 1.5
var drift: float = 0.5
var possessed_steer: float = 1.2
var hit_cooldown: float = 0.5
var hit_zone_scale: float = 1.25
var spin_speed: float = 6.0

var bounce_boost: float = 1.5
var enemy_bounce_boost: float = 2.2
var boost_recovery: float = 300
var squash_amount: float = 0.7
var enemy_squash_amount: float = 0.5

var armour: float = 0.5
var ability_armour: float = 0.8
var ability_speed_bonus: float = 1.4
var ability_bounce_bonus: float = 1.5

var roll_velocity: Vector2 = Vector2.ZERO
var boost_speed: float = 0
var hit_area: Area2D
var sprite_base_scale: Vector2
var squash_tween: Tween

func _ready() -> void:
	super()
	max_health = 30
	current_health = 30
	damage = 6
	ability_duration = 3
	ability_cooldown = 6
	attack_range = 0
	$weapon.hide()
	sprite_base_scale = $sprite.scale


	collision_mask = 0
	set_collision_mask_value(8, true)

	roll_velocity = Vector2.from_angle(randf() * TAU) * roll_speed

	for other in get_tree().get_nodes_in_group("enemy"):
		_ignore_enemy(other)
	get_tree().node_added.connect(_ignore_enemy)

	hit_area = Area2D.new()
	hit_area.collision_layer = 0
	hit_area.collision_mask = 1
	var zone := CollisionShape2D.new()
	zone.shape = $collision_shape.shape
	zone.position = $collision_shape.position
	hit_area.add_child(zone)
	hit_area.scale = Vector2.ONE * hit_zone_scale
	add_child(hit_area)

func _ignore_enemy(other: Node) -> void:
	if other != self and other is CharacterBody2D and other.is_in_group("enemy"):
		other.add_collision_exception_with(self)

func _on_possession() -> void:
	super()
	if get_tree().node_added.is_connected(_ignore_enemy):
		get_tree().node_added.disconnect(_ignore_enemy)
	for other in get_tree().get_nodes_in_group("enemy"):
		if other is CharacterBody2D:
			other.remove_collision_exception_with(self)
			remove_collision_exception_with(other)

func ability_active() -> bool:
	return not $ability_active.is_stopped()

func _process(delta: float) -> void:
	super(delta)
	if state != 'dead':
		$sprite.rotation += spin_speed * delta

func _physics_process(delta: float) -> void:
	if state == 'dead':
		super(delta)
		return
	if effects.has("stun") or not target: return

	var wanted: Vector2 = target.global_position - global_position
	var turn: float = drift
	var cruise: float = roll_speed
	if state == 'possessed':
		wanted = PlayerInfo.get_player_direction()
		turn = possessed_steer
		cruise = roll_speed * possessed_speed_bonus
		if ability_active(): cruise *= ability_speed_bonus
	if wanted != Vector2.ZERO:
		var angle: float = roll_velocity.angle_to(wanted)
		roll_velocity = roll_velocity.rotated(clampf(angle, -turn * delta, turn * delta))

	boost_speed = move_toward(boost_speed, 0, boost_recovery * delta)
	roll_velocity = roll_velocity.normalized() * (cruise + boost_speed)

	var motion: Vector2 = roll_velocity * delta
	if effects.has("slow"): motion *= 0.5
	velocity = motion
	var collision: KinematicCollision2D = move_and_collide(motion)
	if collision:
		_bounce(collision, cruise)
	if state == 'alive':
		_touch_damage()

func _bounce(collision: KinematicCollision2D, cruise: float) -> void:
	roll_velocity = roll_velocity.bounce(collision.get_normal())
	var other: Object = collision.get_collider()
	var hit_enemy: bool = other is Node and other.is_in_group("enemy")
	var spring: float = (enemy_bounce_boost if hit_enemy else bounce_boost) - 1.0
	if ability_active(): spring *= ability_bounce_bonus
	boost_speed = cruise * spring
	if squash_tween: squash_tween.kill()
	$sprite.scale = sprite_base_scale * (enemy_squash_amount if hit_enemy else squash_amount)
	squash_tween = create_tween().set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	squash_tween.tween_property($sprite, "scale", sprite_base_scale, 0.4)
	if state == 'possessed' and hit_enemy and $attack_cooldown.is_stopped():
		other.emit_signal("take_damage", damage)
		$attack_cooldown.start(hit_cooldown)

func _touch_damage() -> void:
	if not $attack_cooldown.is_stopped(): return
	for body in hit_area.get_overlapping_bodies():
		if body != self and body.is_in_group("ally"):
			body.emit_signal("take_damage", damage)
			$attack_cooldown.start(hit_cooldown)
			return

func _on_take_damage(d: float) -> void:
	if state == 'possessed':
		d *= 1.0 - (ability_armour if ability_active() else armour)
	super(d)
