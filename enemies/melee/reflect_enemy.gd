extends "res://enemies/melee/melee_enemy.gd"

const REFLECT_AREA = preload("uid://dje56o45b5stk")
var ability_range : int

func _ready() -> void:
	super()
	max_health = 30
	current_health = 30
	speed = 230
	min_range = 60
	attack_range = 120
	ability_range = 500
	damage = 10
	swing_speed = 0.08
	attack_cooldown = 1

func _process(delta : float) -> void:
	super(delta)
	if state == 'alive':
		var distance: float = global_position.distance_to(target.global_position)
		if distance <= ability_range and $ability_cooldown.is_stopped():
			_on_ability()

##This method describes how the enemy attacks
func _on_attack(direction: Vector2) -> bool:
	return super(direction)

func _on_ability() -> bool:
	if not super(): return false
	var reflect: Area2D = REFLECT_AREA.instantiate()
	if state != 'possessed':
		reflect.attacking_group = "ally"
	else:
		reflect.attacking_group = "enemy"
	reflect.global_position = global_position
	get_tree().current_scene.add_child(reflect)
	_on_take_effect("stun", 3)
	return true
