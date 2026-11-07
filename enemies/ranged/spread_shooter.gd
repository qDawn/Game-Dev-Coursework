extends "res://enemies/enemy.gd"

const ENEMY_BULLET = preload("uid://mq4hucp4nyfe")
const SPLITTING_BULLET = preload("uid://bg0r6w8dw8fou")

#how fast its projectiles move
@export var bullet_speed: int = 500
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

##This method describes how the enemy attacks
func _on_attack(direction: Vector2):
	if $attack_cooldown.is_stopped():
		attack_count += 1
		for i in range(int(-bullet_qty/2.0),int((bullet_qty+1)/2.0)):
			var b: Area2D = SPLITTING_BULLET.instantiate() if attack_count % 3 == 0 else ENEMY_BULLET.instantiate() 
			b.global_position = $weapon/spr/origin.global_position
			b.direction = direction.rotated(PI/12*i)
			b.damage = damage
			b.speed = 400
			if state == 'possessed': b.attacking_group = "enemy"
			get_tree().current_scene.add_child(b)
		$attack_cooldown.start()
		
		#ability indication
		if attack_count % 3 == 0:
			var tween_flash: Tween = create_tween()
			tween_flash.tween_property($halo,"self_modulate",Color(1,1,1,1),0.5)
			tween_flash.tween_property($halo,"self_modulate",Color(1,1,1,0),0.5)

	super(direction)
