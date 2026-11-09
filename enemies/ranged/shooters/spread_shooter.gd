extends "res://enemies/enemy_shooter.gd"

const SPLITTING_BULLET = preload("uid://bg0r6w8dw8fou")

#how fast its projectiles move
var bullet_qty: int = 3
var attack_count: int = 0

func _ready() -> void:
	super()
	max_health = 30
	current_health = 30
	#how fast it moves
	speed = 200
	#how close it gets to the player
	min_range = 100
	#how far it attacks from
	attack_range = 300
	#how fast it can attack
	attack_cooldown = 3.5
	#how fast its projectiles move
	bullet_speed = 500
	#how much damage the projectiles do
	damage = 5
	#how fast the bullet is
	bullet_speed = 500

##This method describes how the enemy attacks
func _on_attack(direction: Vector2) -> bool:
	if not super(direction): return false
	attack_count += 1
	for i in range(int(-bullet_qty/2.0),int((bullet_qty+1)/2.0)):
		if attack_count % 3 == 0:
			fire_bullet(direction.rotated(PI/12*i),bullet_speed,damage,SPLITTING_BULLET)
		else:
			fire_bullet(direction.rotated(PI/12*i),bullet_speed,damage,BASIC_BULLET)
	
	#ability indication
	if attack_count % 3 == 0:
		var tween_flash: Tween = create_tween()
		tween_flash.tween_property($halo,"self_modulate",Color(1,1,1,1),0.5)
		tween_flash.tween_property($halo,"self_modulate",Color(1,1,1,0),0.5)
	return true

func get_ability_cooldown() -> float:
	return (attack_count % 3)/3.0
