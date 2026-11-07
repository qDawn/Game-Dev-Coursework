extends "res://enemies/enemy.gd"

const ENEMY_BULLET = preload("uid://mq4hucp4nyfe")

#how fast its projectiles move
@export var bullet_speed: int = 500

func _ready() -> void:
	super()
	max_health = 20
	current_health = 20
	#how fast it moves
	speed = 200
	#how close it gets to the player
	min_range = 400
	#how far it attacks from
	attack_range = 600
	#how fast it can attack
	attack_cooldown = 3
	#how fast its projectiles move
	bullet_speed = 1000
	#how much damage the projectiles do
	damage = 10
	

##This method describes how the enemy attacks
func _on_attack(direction: Vector2):
	if $attack_cooldown.is_stopped():
		var b: Area2D = ENEMY_BULLET.instantiate()
		b.global_position = $weapon/spr/origin.global_position
		b.direction = direction
		b.damage = damage
		b.speed = bullet_speed
		if state == 'possessed': b.attacking_group = "enemy"
		b.emit_signal("add_effect","slow",3)
		get_tree().current_scene.add_child(b)
		$attack_cooldown.start()
		
	super(direction)
