extends "res://enemies/melee/melee_enemy.gd"

var stun_duration: float = 1
var winding_up: bool = false

func _ready() -> void:
	super()
	# Keep whatever position was set on weapon/spr in the editor.
	max_health = 80
	current_health = 80
	speed = 100
	min_range = 80
	attack_range = 150
	damage = 12
	swing_speed = 0.3
	# The bat recovers in 0.5 seconds. This swing is slower, so the pause is longer.
	attack_cooldown = 1.5

func _process(delta: float) -> void:
	if state != "dead" and state != "possessed":
		if global_position.distance_to(target.global_position) < $slam_area/CollisionShape2D.shape.radius and $ability_cooldown.is_stopped():
			_on_ability()
	super(delta)

func _on_ability() -> bool:
	if not super(): return false

	winding_up = true
	# Raise the hammer
	var tween_windup := create_tween()
	tween_windup.tween_property($weapon, "rotation_degrees", -90.0, 0.55)
	tween_windup.tween_callback(_slam_down)
	#make the area visible
	var tween_area: Tween = create_tween()
	tween_area.tween_property($slam_area/Sprite2D, "self_modulate", Color(1,1,1,1), 0.55)
	tween_area.tween_callback(_slam_down)
	return true

func _on_attack(direction: Vector2) -> bool:
	if winding_up: return false
	return super(direction)

func _on_possession() -> void:
	super()
	stun_duration *= 1.5

func _slam_down() -> void:
	if state == "dead": 
		winding_up = false
		return
	
	#slamming the hammer down
	var tween_slam: Tween = create_tween()
	tween_slam.tween_property($weapon, "rotation_degrees", 90.0, 0.14)
	#making the circle disappear
	var tween_circle: Tween = create_tween()
	tween_circle.tween_property($slam_area/Sprite2D, "self_modulate", Color(1,1,1,0), 0.14)

	var attack_group := "ally" if state != "possessed" else "enemy"
	for body in $slam_area.get_overlapping_bodies():
		if body.is_in_group(attack_group):
			body.emit_signal('take_effect','stun',stun_duration)
			body.emit_signal('take_damage',damage)
	winding_up = false
