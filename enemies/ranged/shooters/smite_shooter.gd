extends "res://enemies/enemy_shooter.gd"

const SMITE_AREA = preload("uid://ccyp3ra11vl6l")
var smite_damage: int = 15
var smite_range : int = 700
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
	#how fast it can attack
	attack_cooldown = 2
	#how fast its projectiles move
	bullet_speed = 500
	#how much damage the projectiles do
	damage = 3
	$ability_cooldown.start(randf_range(1,3))

func _process(delta : float) -> void:
	super(delta)
	if state == 'alive':
		var distance: float = global_position.distance_to(target.global_position)
		if distance <= smite_range and $ability_cooldown.is_stopped():
			_on_ability()

func _on_ability() -> bool:
	if not super(): return false
	var smite: Area2D = SMITE_AREA.instantiate()
	if state != 'possessed':
		smite.global_position = target.global_position + target.velocity*30
		smite.attack_group = "player"
	else:
		smite.global_position = get_global_mouse_position()
		smite.attack_group = "enemy"
	get_tree().current_scene.add_child(smite)
	_on_take_effect("stun", 1)
	#halo
	var tween_flash: Tween = create_tween()
	tween_flash.tween_property($halo,"self_modulate",Color(1,1,1,1),0.5)
	tween_flash.tween_property($halo,"self_modulate",Color(1,1,1,0),0.5)
	return true
