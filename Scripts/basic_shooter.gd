extends "res://Scripts/enemy.gd"

const ENEMY_BULLET = preload("uid://dpygu43fwffkp")

#how fast its projectiles move
@export var bullet_speed: int = 500

func _ready() -> void:
	super()
	max_health = 30
	current_health = 30
	#how fast it moves
	speed = 200
	#how close it gets to the player
	min_range = 200
	#how far it attacks from
	attack_range = 300
	#how fast it can attack
	attack_speed = 10
	#how fast its projectiles move
	bullet_speed = 500
	#damage
	damage = 6


##This method describes how the enemy attacks
func _on_attack(direction: Vector2):
	if not attack_cooldown:
		var b: Area2D = ENEMY_BULLET.instantiate()
		b.global_position = $weapon/spr/origin.global_position
		b.direction = direction
		b.damage = damage
		b.speed = bullet_speed
		if state == 'possessed': b.remove_from_group("enemy_bullet"); b.add_to_group("player_bullet")
		get_tree().current_scene.add_child(b)
		attack_cooldown = true
		$attack_cooldown.start()
