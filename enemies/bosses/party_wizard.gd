extends "res://enemies/ranged/shooters/smite_shooter.gd"
const BASE_MAX_HEALTH: float = 50
const BASE_SPEED: float = 150
const BASE_DAMAGE: float = 5

func _ready() -> void:
	super()
	max_health = BASE_MAX_HEALTH
	current_health = max_health
	speed = BASE_SPEED
	min_range = 400
	attack_range = 600
	attack_cooldown = 3
	bullet_speed = 200
	damage = BASE_DAMAGE
	ability_cooldown = 5
	smite_scale = Vector2(2,2)
	default_bullet = preload("uid://opb7dv63vy0u")

func _on_decay_timer_timeout() -> void:
	#lose 5% health 
	current_health -= int(max_health*0.1)
	if current_health <= 0 and state == 'possessed': 
		#send signal to player that the possessed vessel has died.
		get_tree().get_first_node_in_group('player').emit_signal('cancel_possession')
		revive()

func _on_take_damage(d: float) -> void:
	if current_health - d <= 0 and state == 'possessed':
		get_tree().get_first_node_in_group('player').emit_signal('cancel_possession')
		revive()
	else: 
		super(d)

func _on_possession_window_timeout() -> void:
	revive()

func fire_bullet(direction: Vector2, b_speed: float, b_damage: float, bullet_type: Resource) -> Area2D:
	var b: HomingBullet = bullet_type.instantiate()
	b.global_position = $weapon/spr/origin.global_position
	b.direction = Vector2.from_angle(direction.angle() + randf_range(-PI/36*inaccuracy, PI/36*inaccuracy))
	b.damage = b_damage
	b.speed = b_speed
	b.follow_duration = 3
	if state == 'possessed': b.attacking_group = "enemy"
	else: b.attacking_group = "ally"
	get_tree().current_scene.add_child(b)
	return b

func revive():
	remove_from_group("ally")
	add_to_group("enemy")
	max_health = BASE_MAX_HEALTH
	current_health = max_health
	speed = BASE_SPEED
	damage = BASE_DAMAGE
	state = 'alive'
	emit_signal("take_effect","stun",3)
	$retarget_cooldown.emit_signal("timeout")
	#reset the collision layers (so the possessed enemy can take damage again
	set_collision_layer_value(1,true)
	set_collision_layer_value(2,false)
	#make the sprite visible again
	$sprite.self_modulate = Color(1,1,1,1)
	$corpse_timer.hide()
