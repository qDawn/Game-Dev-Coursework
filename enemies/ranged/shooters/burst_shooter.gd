extends "res://enemies/superclasses/enemy_shooter.gd"

const BASE_BURST_MAX_COUNT: int = 3
const BASE_ATTACK_COOLDOWN: float = 2
const BASE_INACCURACY: float = 1.2

var burst_max_count: int = 3
var burst_current_count: int = 0
var enhance_count: int = 0

func _ready() -> void:
	super()
	max_health = 20
	current_health = 20
	speed = 220
	min_range = 160
	attack_range = 340
	attack_cooldown = 2
	damage = 2
	attack_cooldown = BASE_ATTACK_COOLDOWN
	bullet_speed = 700
	ability_duration = 4
	inaccuracy = BASE_INACCURACY

func _on_attack(direction: Vector2) -> bool:
	if not super(direction): return false
	burst_current_count = 0
	$burst_timer.start()
	return true

func _on_burst_timer_timeout() -> void:
	#if the max burst has been reached, stop calling itself
	if state == "dead" or burst_current_count == burst_max_count: 
		if randf() <= 0.1 and enhance_count < 3:
			enhance()
		return
	#spawn bullet
	var direction: Vector2 = Vector2.from_angle($weapon.rotation)
	fire_bullet(direction,bullet_speed,damage,BASIC_BULLET)
	burst_current_count += 1
	$burst_timer.start()

func _on_ability() -> bool:
	if not super(): return false
	enhance()
	$attack_cooldown.stop()
	return true

func enhance() -> void:
	$ability_active.start(ability_cooldown)
	enhance_count += 1
	burst_max_count += 1
	attack_cooldown -= 0.5
	$halo.visible = true

func _on_ability_active_timeout() -> void:
	super()
	burst_max_count = BASE_BURST_MAX_COUNT
	attack_cooldown = BASE_ATTACK_COOLDOWN
	inaccuracy = BASE_INACCURACY
	$halo.visible = false

func _on_take_damage(d: float) -> void:
	super(d)
	if state == "dead":
		_on_ability_active_timeout()

func _on_possession() -> void:
	super()
	ability_duration *= 1.5
