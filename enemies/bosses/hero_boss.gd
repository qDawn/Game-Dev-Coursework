extends "res://enemies/superclasses/melee_enemy.gd"

const BASIC_BULLET = preload("uid://mq4hucp4nyfe")
var projectile_speed = 500
var last_attack_direction: Vector2
var attack_count: int = 0
var attack_max_count: int = 2

func _ready() -> void:
	super()
	max_health = 1
	current_health = 1
	speed = 100
	min_range = 80
	attack_range = 600
	damage = 8
	attack_cooldown = 3

func _on_attack(direction: Vector2) -> bool:
	if PlayerInfo.possession_target and PlayerInfo.possession_target.is_in_group("hero_party"): return false
	last_attack_direction = direction
	return super(direction)

##Method to fire a bullet.
func fire_bullet(direction: Vector2, b_speed: float, b_damage: float, bullet_type: Resource) -> Area2D:
	var b: BasicBullet = bullet_type.instantiate()
	b.global_position = $weapon/spr/origin.global_position
	b.direction = direction
	b.damage = b_damage
	b.speed = b_speed
	b.attacking_group = "ally"
	get_tree().current_scene.add_child(b)
	return b

func _on_take_damage(d: float) -> void:
	if PlayerInfo.possession_target and PlayerInfo.possession_target.is_in_group("hero_party"): d *= 2
	
	var tween_damage: Tween = get_tree().create_tween()
	tween_damage.tween_property($sprite,"self_modulate",Color(1,0,0),0.1)
	tween_damage.tween_property($sprite,"self_modulate",Color(1,1,1),0.1)
	
	var damage_ui: Label = preload("res://ui/damage_ui.tscn").instantiate()
	damage_ui.text = str(d)
	damage_ui.global_position = Vector2(global_position.x+20,global_position.y-20)
	
	get_tree().root.add_child(damage_ui)
	$"..".emit_signal("take_damage",d)

func _on_attack_end():
	for i in range(-2,3):
		fire_bullet(last_attack_direction.rotated(PI/12*i),projectile_speed,damage,BASIC_BULLET)
	if attack_count < attack_max_count:
		attack_count += 1
		$attack_cooldown.stop()
	else:
		attack_count = 0
