extends "res://enemies/enemy.gd"
const ENEMY_BULLET = preload("uid://mq4hucp4nyfe")

@export var bullet_speed: int = 700
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

func _on_attack(direction: Vector2) -> bool:
	if not super(direction): return false
	burst_count = 0
	$burst_timer.start()
	return true

func _on_burst_timer_timeout() -> void:
	#if the max burst has been reached, stop calling itself
	if state == "dead" or burst_count == burst_max_count: return
	#spawn bullet
	var bullet: Area2D = ENEMY_BULLET.instantiate()
	bullet.global_position = $weapon/spr/origin.global_position
	bullet.direction = Vector2.from_angle($weapon.rotation + randf_range(-PI/36, PI/36))
	bullet.damage = damage
	bullet.speed = bullet_speed
	if state == 'possessed': bullet.attacking_group = "enemy"
	get_tree().current_scene.add_child(bullet)
	burst_count += 1
	$burst_timer.start()
