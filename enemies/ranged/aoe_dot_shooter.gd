extends "res://enemies/enemy_shooter.gd"

const AOE_DOT_BULLET = preload("uid://48j178s0vo16")
var dot_damage: float = 0.5

func _ready() -> void:
	super()
	max_health = 20
	current_health = 20
	#how fast it moves
	speed = 200
	#how close it gets to the player
	min_range = 200
	#how far it attacks from
	attack_range = 300
	#how fast it can attack
	attack_cooldown = 2.5
	#how fast its projectiles move
	bullet_speed = 500
	#damage
	damage = 4

##This method describes how the enemy attacks
func _on_attack(direction: Vector2) -> bool:
	if not super(direction): return false
	var b: Area2D = fire_bullet(direction, bullet_speed, damage, AOE_DOT_BULLET)
	b.dot_damage = dot_damage
	return true

func _on_ability() -> bool:
	if not super(): return false
	var direction: Vector2 = Vector2.from_angle($weapon.rotation)
	var b: Area2D = fire_bullet(direction, bullet_speed, damage, AOE_DOT_BULLET)
	b.size = 1.5
	b.dot_damage = dot_damage
	return true

func _on_possession() -> void:
	super()
	dot_damage = 1
