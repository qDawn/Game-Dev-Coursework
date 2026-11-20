extends "res://enemies/superclasses/melee_enemy.gd"

const BASIC_BULLET = preload("uid://mq4hucp4nyfe")
var projectile_speed = 500
var last_attack_direction: Vector2
var attack_count: int = 0
var attack_max_count: int = 2


func _ready() -> void:
	super()
	max_health = 500
	current_health = 500
	speed = 200
	min_range = 80
	attack_range = 600
	damage = 8
	attack_cooldown = 3

func _on_attack(direction: Vector2) -> bool:
	last_attack_direction = direction
	return super(direction)



##Method to fire a bullet.
func fire_bullet(direction: Vector2, b_speed: float, b_damage: float, bullet_type: Resource) -> Area2D:
	var b: BasicBullet = bullet_type.instantiate()
	b.global_position = $weapon/spr/origin.global_position
	b.direction = direction
	b.damage = b_damage
	b.speed = b_speed
	if state == 'possessed': b.attacking_group = "enemy"
	else: b.attacking_group = "ally"
	get_tree().current_scene.add_child(b)
	return b

func _on_take_damage(d: float) -> void:
	super(d)
	if state == "dead": queue_free()

func _on_attack_end():
	for i in range(-2,3):
		fire_bullet(last_attack_direction.rotated(PI/12*i),projectile_speed,damage,BASIC_BULLET)
	if attack_count < attack_max_count:
		attack_count += 1
		$attack_cooldown.stop()
	else:
		attack_count = 0
