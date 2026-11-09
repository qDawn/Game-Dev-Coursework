extends "res://enemies/enemy.gd"

const BASIC_BULLET = preload("uid://mq4hucp4nyfe")

##how fast its bullets move
var bullet_speed: int = 500

##This method describes how the enemy attacks
func _on_attack(direction: Vector2) -> bool:
	if not super(direction): return false
	fire_bullet(direction, bullet_speed, damage, BASIC_BULLET)
	return true

##Method to fire a bullet.
func fire_bullet(direction: Vector2, b_speed: float, b_damage: float, bullet_type: Resource) -> Area2D:
	var b: Area2D = bullet_type.instantiate()
	b.global_position = $weapon/spr/origin.global_position
	b.direction = direction
	b.damage = b_damage
	b.speed = b_speed
	if state == 'possessed': b.attacking_group = "enemy"
	else: b.attacking_group = "ally"
	get_tree().current_scene.add_child(b)
	return b
