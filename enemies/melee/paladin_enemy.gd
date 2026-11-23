extends "res://enemies/superclasses/melee_enemy.gd"

const max_ability_speed: float = 410
#Attacks faster during ability
const ability_attack_cooldown : float = 0.8
#Swings faster during ability
const ability_swing_speed: float = 0.15
#Attacks from further away during ability
const ability_min_range: float = 130

const base_min_range: float = 80
const base_speed: float = 200
const base_attack_cooldown: float = 1.2
const max_barrier_health: float = 16 
const ability_range: float = 400

var barrier_health : float = max_barrier_health
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
	ability_duration = 4
	$barrier.hide()
	$ability_weapon.hide()

func _process(delta: float) -> void:
	super(delta)
	if not state == "possessed" and not state == "dead" and global_position.distance_to(target.global_position) > ability_range:
		_on_ability()
	if ability_on:
		speed = min(max_ability_speed, speed + 250*delta)
		
	
func _physics_process(delta: float) -> void:
	super(delta)
	if ability_on and attacking:
		handle_weapon_collision($ability_weapon/Area2D)
	
func _on_attack(direction: Vector2) -> bool:
	if attacking: return false
	if !ability_on:
		return super(direction)
	else:
		if !($attack_cooldown.is_stopped() and not effects.has("stun")): return false
		$attack_cooldown.start(attack_cooldown)
		if effects.has("bleed"): _on_take_damage(damage)
		
		attacking = true
		var direction_angle: float = 180*direction.angle()/PI
		direction_multiplier *= -1

		#swinging the weapon
		$ability_weapon.rotation_degrees -= direction_multiplier*70
		#tween for swinging
		var tween_swing: Tween = get_tree().create_tween()
		tween_swing.tween_property($ability_weapon, "rotation_degrees", direction_angle+direction_multiplier*100, ability_swing_speed)
		tween_swing.tween_property($'.', "attacking", false, 0)

		#clear the array of entities hit
		already_hit.clear()
		return true
	
func _on_ability() -> bool:
	if not super(): return false
	attack_cooldown = ability_attack_cooldown
	$attack_cooldown.start(attack_cooldown)
	min_range = ability_min_range
	barrier_health = max_barrier_health
	$barrier.show()
	$weapon.hide()
	$ability_weapon.show()
	ability_on = true
	return true

func _on_ability_active_timeout() -> void:
	ability_on = false
	speed = base_speed
	attack_cooldown = base_attack_cooldown
	min_range = base_min_range
	barrier_health = 0
	$barrier.hide()
	$weapon.show()
	$ability_weapon.hide()
	super()
	
func _on_take_damage(d: float) -> void:
	#barrier absorbs the damage. If damage exceeds barrier health, enemy takes remaining damage
	if barrier_health > 0:
		barrier_health = barrier_health - d
		#Barrier removes when health <= 0 and damage is taken when damage > 0
		if barrier_health <=0:
			$barrier.hide()
		if barrier_health < 0:
			super(-barrier_health)
	else:
		super(d)
		
func aim(direction: Vector2):
	if !ability_on:
		super(direction)
	else:
		if !attacking and not effects.has("stun"):
			if direction.x < 0: $ability_weapon.scale.y = -1
			else: $ability_weapon.scale.y = 1
			$ability_weapon.rotation = direction.angle()
		
