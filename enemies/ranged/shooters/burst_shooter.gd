extends "res://enemies/enemy_shooter.gd"

var burst_max_count: int = 3
var burst_count: int = 3

func _ready() -> void:
	super()
	max_health = 20
	current_health = 20
	speed = 220
	min_range = 160
	attack_range = 340
	attack_cooldown = 2
	damage = 2
	attack_cooldown = 2
	bullet_speed = 700

func _on_attack(direction: Vector2) -> bool:
	if not super(direction): return false
	burst_count = 0
	$burst_timer.start()
	return true

func _on_burst_timer_timeout() -> void:
	#if the max burst has been reached, stop calling itself
	if state == "dead" or burst_count == burst_max_count: return
	#spawn bullet
	var direction: Vector2 = Vector2.from_angle($weapon.rotation + randf_range(-PI/36, PI/36))
	fire_bullet(direction,bullet_speed,damage,BASIC_BULLET)
	burst_count += 1
	$burst_timer.start()
