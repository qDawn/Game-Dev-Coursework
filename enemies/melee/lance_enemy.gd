extends "res://enemies/melee/melee_enemy.gd"

var max_normal_speed : int
var max_charge_speed : int
var ability_on :bool = false

# make the sprite lime bike lancers
# after it collides with 1 enemy, charge stops 

func _ready() -> void:
	super()
	max_health = 35
	current_health = 35
	speed = 250
	max_normal_speed = 250
	max_charge_speed = 1000
	min_range = 70
	attack_range = 180
	damage = 10
	attack_cooldown = 1
	ability_duration = 2.5
	
func _on_attack(_direction: Vector2) -> bool:
	if !($attack_cooldown.is_stopped() and not effects.has("stun")): return false
	if effects.has("bleed"): _on_take_damage(damage)
	
	attacking = true

	#tween for extending
	var tween_extend: Tween = get_tree().create_tween()
	tween_extend.tween_property($weapon/spr, "position", Vector2(64,0), swing_speed)
	tween_extend.tween_property($weapon/spr, "position", Vector2(32,0), 0)
	tween_extend.tween_property($'.', "attacking", false, 0)
	#weapon collison
	$attack_cooldown.start(attack_cooldown)
	
	#clear the array of entities hit
	already_hit.clear()
	return true
	
func _process(delta : float) -> void:
	if !ability_on or state == 'dead':
		super(delta)
		if state == 'alive':
			_on_ability()
			if speed > max_normal_speed:
				speed = min(max_normal_speed, speed - 500*delta)
	else:
		
		if speed < max_charge_speed:
			speed += 250*delta
		
func _physics_process(delta: float) -> void:
	if !ability_on or state == "dead":
		super(delta)
		return
		
	# if ability is on, the direction cannot be changed
	if effects.has("stun") or not target: return
	if effects.has("slow"): velocity *= 0.5
	move_and_collide(velocity)
	
func _on_take_damage(d: float) -> void:
	super(d)
	if state == "dead":
		ability_on = false
		speed = max_normal_speed

func _on_ability() -> bool:
	if not super(): return false
	
	speed = max_normal_speed + 50
	ability_on = true
	return true
	
func _on_ability_active_timeout() -> void:
	super()
	ability_on = false

	
