extends "res://enemies/superclasses/enemy_shooter.gd"

const HOMING_BULLET = preload("uid://opb7dv63vy0u")

var bullet_piercing: int = 2

func _ready() -> void:
	super()
	max_health = 20
	current_health = 20
	speed = 200
	min_range = 400
	attack_range = 600
	attack_cooldown = 3
	bullet_speed = 1000
	damage = 10
	ability_duration = 5
	
##This method describes how the enemy attacks
func _on_attack(direction: Vector2) -> bool:
	if not super(direction): return false
	
	var b: Area2D = fire_bullet(direction, bullet_speed, damage, BASIC_BULLET) if $ability_active.is_stopped() else fire_bullet(direction, bullet_speed, damage, HOMING_BULLET)
	if not effects.has("silence"):
		b.emit_signal("add_effect","silence",3)
		b.emit_signal("add_effect","slow",3)
	b.piercing = bullet_piercing
	return true

func _on_ability() -> bool:
	if not super(): return false
	attack_cooldown = 2
	bullet_piercing = 3
	return true

func _on_ability_active_timeout() -> void:
	attack_cooldown = 3
	bullet_piercing = 2
