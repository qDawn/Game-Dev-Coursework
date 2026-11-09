extends "res://enemies/enemy.gd"

const ENEMY_BULLET = preload("uid://mq4hucp4nyfe")
const SMITE_AREA = preload("uid://ccyp3ra11vl6l")
@export var bullet_speed : int
@export var bullet_damage : int 
@export var smite_damage : int
@export var smite_range : int
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super()
	max_health = 25
	current_health = 25
	#how fast it moves
	speed = 200
	#how close it gets to the player
	min_range = 300
	#how far it attacks from
	attack_range = 500
	#how far it can activate ability from
	smite_range = 700
	#how fast it can attack
	attack_cooldown = 3
	#how fast its projectiles move
	bullet_speed = 500
	#how much damage the projectiles do
	bullet_damage = 3
	#how much damage the smite ability does
	smite_damage = 15

func _process(delta : float) -> void:
	super(delta)
	if state == 'alive':
		var distance: float = global_position.distance_to(target.global_position)
		if distance <= smite_range and $ability_cooldown.is_stopped():
			_on_ability()
			
func _on_attack(direction: Vector2) -> bool:
	if not super(direction): return false
	var b: Area2D = ENEMY_BULLET.instantiate()
	b.global_position = $weapon/spr/origin.global_position
	b.direction = direction
	b.damage = damage
	b.speed = bullet_speed
	if state == 'possessed': 
		b.attacking_group = "enemy"
	else:
		b.attacking_group = "ally"
	get_tree().current_scene.add_child(b)
	return true
		
func _on_ability() -> bool:
	if not super(): return false
	var smite: Area2D = SMITE_AREA.instantiate()
	if state != 'possessed':
		smite.global_position = get_tree().get_first_node_in_group('player').global_position
		smite.attack_group = "player"
	else:
		smite.global_position = get_global_mouse_position()
		smite.attack_group = "enemy"
	get_tree().current_scene.add_child(smite)
	_on_take_effect("stun", 1)
	return true
