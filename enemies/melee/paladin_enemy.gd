extends "res://enemies/superclasses/melee_enemy.gd"

const max_ability_speed : int= 400
const base_speed : int = 150
const base_attack_cooldown = 1.2
const base_swing_speed = 0.1
const ability_attack_cooldown : float = 0.5
const ability_swing_speed = 0.05
const max_barrier_health : int = 16 
const ability_range :int = 400

var barrier_health : int = max_barrier_health
var ability_on :bool = false

func _ready() -> void:
	super()
	max_health = 35
	current_health = 35
	speed = base_speed
	min_range = 50
	attack_range = 150
	damage = 10
	attack_cooldown = 1.2
	ability_duration = 3
	$barrier.hide()

func _process(delta: float) -> void:
	super(delta)
	if not state == "possessed" and not state == "dead" and global_position.distance_to(target.global_position) > ability_range:
		_on_ability()
	if ability_on:
		speed = min(max_ability_speed, speed + 250*delta)
	
func _on_attack(direction: Vector2) -> bool:
	attacking = true
	var direction_angle: float = 180*direction.angle()/PI
	direction_multiplier *= -1

	#swinging the weapon
	$weapon.rotation_degrees -= direction_multiplier*70
	#tween for swinging
	var tween_swing: Tween = get_tree().create_tween()
	tween_swing.tween_property($weapon, "rotation_degrees", direction_angle+direction_multiplier*70, swing_speed)
	tween_swing.tween_property($'.', "attacking", false, 0)
	#weapon collison
	$weapon_collision.rotation_degrees = direction_angle
	
	#clear the array of entities hit
	already_hit.clear()
	return true
	
func _on_ability() -> bool:
	if not super(): return false
	$barrier.show()
	ability_on = true
	attack_cooldown = ability_attack_cooldown
	$attack_cooldown.stop()
	swing_speed = ability_swing_speed
	barrier_health = max_barrier_health
	$weapon.scale = Vector2(2,2)
	return true

func _on_ability_active_timeout() -> void:
	$barrier.hide()
	ability_on = false
	speed = base_speed
	attack_cooldown = base_attack_cooldown
	swing_speed = base_swing_speed
	barrier_health = 0
	$weapon.scale = Vector2(1,1)
	super()
	
func _on_take_damage(d: float) -> void:
	#barrier absorbs the damage. If damage exceeds barrier health, enemy takes remaining damage
	if barrier_health > 0:
		barrier_health = barrier_health - d
		if barrier_health < 0:
			super(-barrier_health)
			$barrier.hide()
	else:
		super(d)
