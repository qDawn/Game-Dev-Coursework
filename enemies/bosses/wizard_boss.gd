extends "res://enemies/ranged/shooters/smite_shooter.gd"
const BASE_MAX_HEALTH: float = 40
const BASE_SPEED: float = 100
const BASE_DAMAGE: float = 5

func _ready() -> void:
	super()
	max_health = BASE_MAX_HEALTH
	current_health = max_health
	speed = BASE_SPEED
	min_range = 400
	attack_range = 600
	attack_cooldown = 3
	bullet_speed = 400
	damage = BASE_DAMAGE
	ability_cooldown = 5
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
