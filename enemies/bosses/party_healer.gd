extends "res://enemies/ranged/shooters/aoe_dot_shooter.gd"
const BASE_MAX_HEALTH: float = 40
const BASE_SPEED: float = 200
const BASE_DAMAGE: float = 5

func _ready() -> void:
	super()
	max_health = BASE_MAX_HEALTH
	current_health = max_health
	speed = BASE_SPEED
	min_range = 200
	attack_range = 300
	attack_cooldown = 3
	bullet_speed = 500
	damage = BASE_DAMAGE
	ability_cooldown = 5

func _process(_delta: float) -> void:
	super(_delta)

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

func _on_retarget_cooldown_timeout() -> void:
	var target_group: String = 'hero_party'
	var lowest: Enemy = null
	for t: Enemy in get_tree().get_nodes_in_group(target_group):
		if (t.current_health / t.max_health) > 0.8 or t == self: continue
		if not lowest or (t.current_health/t.max_health) < (lowest.current_health/lowest.max_health):
			lowest = t
	target = lowest
	if not target: super()

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
