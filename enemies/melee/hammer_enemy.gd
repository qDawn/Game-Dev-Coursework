extends "res://enemies/melee/melee_enemy.gd"


var slamming: bool = false
var slam_radius: float = 180.0
var ring_alpha: float = 0.0
var ring_fading: bool = false
var hammer_rest: Vector2

func _ready() -> void:
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
	$slam_area/CollisionShape2D.shape.radius = slam_radius

func _process(delta: float) -> void:
	if state == "alive" and not ability_cooldown and not attacking and not effects.has("stun"):
		var player := get_tree().get_first_node_in_group("player")
		if player and global_position.distance_to(player.global_position) <= slam_radius:
			_on_ability()
	super(delta)
	if ring_fading:
		ring_alpha = max(ring_alpha - delta * 1.4, 0.0)
		if ring_alpha == 0.0:
			ring_fading = false
	if ring_alpha > 0.0:
		queue_redraw()

func _draw() -> void:
	if ring_alpha <= 0.0:
		return
	draw_arc(Vector2.ZERO, slam_radius, 0, TAU, 48, Color(1, 0.78, 0.15, ring_alpha), 6.0)

func _on_ability() -> bool:
	if not super(): return false
	if slamming or attacking: return false
	ability_cooldown = true
	slamming = true
	attacking = true
	ring_alpha = 0.75
	ring_fading = false
	queue_redraw()

	# Raise the hammer, then the impact callback brings it down.
	var windup := create_tween()
	windup.tween_property($weapon, "rotation_degrees", -90.0, 0.55)
	windup.tween_callback(_slam_down)
	
	return true

func _slam_down() -> void:
	if not is_inside_tree() or state == "dead":
		_finish_slam()
		return
	var slam := create_tween()
	slam.tween_property($weapon, "rotation_degrees", 90.0, 0.14)
	slam.tween_callback(_slam_impact)

func _slam_impact() -> void:
	if not is_inside_tree() or state == "dead":
		_finish_slam()
		return
	ring_alpha = 1.0
	ring_fading = true
	var attack_group := "player" if state != "possessed" else "enemy"
	for body in $slam_area.get_overlapping_bodies():
		if body == self or not body.is_in_group(attack_group):
			continue
		if attack_group == "enemy" and body.get("state") != "alive":
			continue
		body.emit_signal('take_effect','stun',1)
	_finish_slam()

func _finish_slam() -> void:
	slamming = false
	attacking = false
	ring_fading = true
	if not is_inside_tree() or state == "dead" or effects.has("stun"):
		return
	$weapon/spr.position = hammer_rest
	$attack_cooldown.start()

func _can_hit(body: Node) -> bool:
	if state == "possessed":
		return body.is_in_group("enemy") and body.get("state") == "alive"
	return body.is_in_group("player")
