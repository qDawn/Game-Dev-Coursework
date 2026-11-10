extends CharacterBody2D

signal attack
signal ability
signal take_damage
signal heal
signal take_effect
signal possession

#health
var max_health: float = 10
var current_health: float = 10

##how fast the enemy moves
var speed: float = 200
##how close the enemy moves to the player
var min_range: float = 200
##how far the enemy attacks from
var attack_range: float = 500
##how long the attack cooldown is
var attack_cooldown: float = 1
##how much damage the enemy does
var damage: float = 5
##How long the ability cooldown is
var ability_cooldown: float = 6
##how long the ability lasts
var ability_duration: float = 0.01
##valid states include: 'alive', 'dead', 'possessed'
var state: String = 'alive'

## Stores effects of the enemy. Format: {name: duration}
## current effects include: slow, bleed, stun, silence.
var effects : Dictionary[String,float] = {}
#whether the enemy is currently attacking
var attacking : bool = false
#how fast the enemy can move its weapon
var aim_speed : float = 5
#whether the enemy is currently moving weapon to aim
var target: CharacterBody2D


func _ready() -> void:
	connect("attack",_on_attack)
	connect("ability",_on_ability)
	connect("take_damage",_on_take_damage)
	connect("heal",_on_heal)
	connect("take_effect",_on_take_effect)
	connect("possession",_on_possession)
	
	target = get_tree().get_first_node_in_group('ally')

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if state != 'dead' and target:
		var direction: Vector2
		var distance: float
		if state == 'possessed':
			direction = global_position.direction_to(get_global_mouse_position())
			aim(direction, delta)
		else:
			direction = global_position.direction_to(target.global_position)
			aim(direction, delta)
			
			distance = global_position.distance_to(target.global_position)
			#if player is in attack range, attack
			if distance <= attack_range and $attack_cooldown.is_stopped() and $hesitation_timer.is_stopped() and not effects.has("stun"):
				$exclamation.visible = true
				$hesitation_timer.start(randf_range(0.1,1.5))

	else:
		#update the corpse timer bar with the time left to possess
		$corpse_timer.value = $possession_window.time_left

func _physics_process(delta: float) -> void:
	# Skip if enemy is dead or stunned in effects
	if effects.has("stun") or not target: return
	velocity = Vector2.ZERO
	if state == 'alive':
		var distance: float = global_position.distance_to(target.global_position)
		if abs(distance - min_range) < 10: return

		var direction: Vector2 = global_position.direction_to(target.global_position+target.velocity*target.speed*delta*5)
		if distance < min_range: direction *= -0.5
		velocity += direction*speed*delta

	elif state == 'possessed':
		#move in the direction the player moves
		velocity = PlayerInfo.get_player_direction()*speed*delta

	if effects.has("slow"): velocity *= 0.5
	move_and_collide(velocity)

##This method describes how the enemy attacks. Returns true if successful. False otherwise.
func _on_attack(_direction: Vector2) -> bool:
	if $attack_cooldown.is_stopped() and not effects.has("stun"):
		$attack_cooldown.start(attack_cooldown)
		if effects.has("bleed"): _on_take_damage(damage)
		return true
	return false

#This method describes what the enemy does for its ability. Returns true if successful. False otherwise.
func _on_ability() -> bool: 
	if $ability_cooldown.is_stopped() and $ability_active.is_stopped() and not effects.has("silence"): 
		$ability_active.start(ability_duration)
		return true
	return false

func _on_take_damage(d: float) -> void:
	current_health -= d
	if current_health <= 0: 
		if state == 'alive':
			state = 'dead'
			PlayerInfo.add_score(PlayerInfo.get_kill_points(scene_file_path.get_file().get_basename()))
			$possession_window.start()
			#set up and show the corpse timer bar
			$corpse_timer.max_value = $possession_window.wait_time
			$corpse_timer.value = $possession_window.wait_time
			$corpse_timer.show()
			set_collision_layer_value(1,false)
			set_collision_mask_value(1,false)
			$sprite.self_modulate = Color(1,1,1,0.5)
		elif state == 'possessed':
			#send signal to player that the possessed vessel has died.
			get_tree().get_first_node_in_group('player').emit_signal('cancel_possession')
			queue_free()
			
	#damage indication
	if not state == "dead":
		var tween_damage: Tween = get_tree().create_tween()
		tween_damage.tween_property($sprite,"self_modulate",Color(1,0,0),0.1)
		tween_damage.tween_property($sprite,"self_modulate",Color(1,1,1),0.1)
	
	var damage_ui: Label = preload("res://ui/damage_ui.tscn").instantiate()
	damage_ui.text = str(d)
	damage_ui.global_position = Vector2(global_position.x+20,global_position.y-20)
	get_tree().root.add_child(damage_ui)

func _on_heal(h: float) -> void:
	if not state == "dead":
		current_health = min(current_health+h,max_health)
		var damage_ui: Label = preload("res://ui/damage_ui.tscn").instantiate()
		damage_ui.text = "+%s" % h
		damage_ui.global_position = Vector2(global_position.x+20,global_position.y-20)
		damage_ui.add_theme_color_override("font_color",Color(0,1,0,1))
		get_tree().root.add_child(damage_ui)

func _on_ability_active_timeout() -> void:
	$ability_cooldown.start(ability_cooldown)

func _on_ability_cooldown_timeout() -> void:
	pass
func _on_possession_window_timeout() -> void:
	queue_free()

func _on_possession() -> void:
	#stop the deletion from not being possessed.
	$possession_window.stop()
	#set the state to possessed.
	state = 'possessed'
	#reset the collision layers (so the possessed enemy can take damage again
	set_collision_layer_value(1,true)
	set_collision_mask_value(1,true)
	#make the sprite visible again
	$sprite.self_modulate = Color(1,1,1,1)
	#bleed tints modulate and leaves it on the corpse
	$sprite.modulate = Color.WHITE
	#recover hp + bonus hp
	max_health *= 1.5
	current_health = max_health
	#reset movement
	effects.clear()
	#damage bonus
	damage *= 1.5
	#speed bonus
	speed *= 1.5
	#start decaying
	$decay_timer.start()
	#remove from enemy group
	remove_from_group("enemy")
	#add to player group
	add_to_group("ally")
	#hide the corpse timer bar
	$corpse_timer.hide()

func _on_decay_timer_timeout() -> void:
	#lose 5% health 
	current_health -= int(max_health*0.05)
	if current_health <= 0: 
		#send signal to player that the possessed vessel has died.
		get_tree().get_first_node_in_group('player').emit_signal('cancel_possession')
		queue_free()

func _on_effect_timer_timeout() -> void:
	for effect in effects:
		effects[effect] -= 0.5
		if effects[effect] <= 0: effects.erase(effect)

func _on_take_effect(effect: String, duration: float) -> void:
	effects[effect] = max(effects.get(effect,0),duration)

#Method for aiming the weapon
func aim(direction: Vector2, delta : float):
	if !attacking and not effects.has("stun"):
		if direction.x < 0: $weapon.scale.y = -1
		else: $weapon.scale.y = 1
		$weapon.rotation = lerp_angle($weapon.rotation, direction.angle(), delta * aim_speed)
		
func _on_hesitation_timer_timeout() -> void:
	$exclamation.visible = false
	if state == "alive":
		_on_attack(Vector2.from_angle($weapon.rotation))

#Method to get the current ability cooldown/active remaining time.
func get_ability_cooldown() -> float:
	if not $ability_active.is_stopped():
		return $ability_active.time_left/$ability_active.wait_time
	elif not $ability_cooldown.is_stopped():
		return 1-$ability_cooldown.time_left/$ability_cooldown.wait_time
	return 1
