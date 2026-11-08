extends "res://enemies/enemy.gd"

const ENEMY_BULLET = preload("uid://mq4hucp4nyfe")
#how fast its projectiles move
@export var bullet_speed: int = 500
const base_speed: float = 200
const base_attack_cooldown: float = 1
var used_ability: bool = false
func _ready() -> void:
	super()
	max_health = 25
	current_health = 25
	#how fast it moves
	speed = base_speed
	#how close it gets to the player
	min_range = 200
	#how far it attacks from
	attack_range = 300
	#how fast it can attack
	attack_cooldown = base_attack_cooldown
	#how fast its projectiles move
	bullet_speed = 500
	#damage
	damage = 6
	#how long the ability lasts
	ability_duration = 2


func _on_take_damage(num: float) -> void:
	#at less than half hp, use ability.
	if current_health - num <= max_health*0.5 and $ability_cooldown.is_stopped() and state != "possessed" and not used_ability:
		_on_ability()
	if current_health - num <= 0 and not $ability_active.is_stopped():
		current_health = num + 1
	super(num)
	if state == "dead":
		_on_ability_active_timeout()

func _on_decay_timer_timeout() -> void:
	if $ability_active.is_stopped():
		super()

func _on_possession() -> void:
	super()
	ability_duration *= 2

##This method describes how the enemy attacks
func _on_attack(direction: Vector2) -> bool:
	if not super(direction): return false
	var b: Area2D = ENEMY_BULLET.instantiate()
	b.global_position = $weapon/spr/origin.global_position
	b.direction = direction
	b.damage = damage
	b.speed = bullet_speed
	if state == 'possessed': b.attacking_group = "enemy"
	get_tree().current_scene.add_child(b)
	return true

func _on_ability() -> bool:
	if not super(): return false
	used_ability = true
	speed *= 1.5
	attack_cooldown /= 1.5
	$halo.visible = true
	$attack_cooldown.stop()
	return true

func _on_ability_active_timeout() -> void:
	speed = base_speed
	attack_cooldown = base_attack_cooldown
	$halo.visible = false
