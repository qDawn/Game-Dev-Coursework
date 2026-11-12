extends "res://projectiles/basic_bullet.gd"

func _physics_process(delta: float) -> void:
	super(delta)
	if not $follow_timer.is_stopped():
		var target: Node2D = seek_closest_target()
		if target:
			var direction_to_target: Vector2 = global_position.direction_to(seek_closest_target().global_position)
			if abs(direction.x) > abs(direction.y): direction.y = lerp(direction.y, direction_to_target.y,0.1)
			else: direction.x = lerp(direction.x, direction_to_target.x,0.2)

func seek_closest_target() -> Node2D:
	var closest: Node2D = get_tree().get_first_node_in_group(attacking_group)
	for target: Node2D in get_tree().get_nodes_in_group(attacking_group):
		if target.is_in_group("enemy") and target.state == "dead": continue
		var target_pos: Vector2= target.global_position
		if global_position.distance_to(target_pos) < global_position.distance_to(closest.global_position):
			#check that the target is in the same direction that the bullet is moving
			var target_direction: Vector2 = global_position.direction_to(target_pos)
			if abs(direction.angle_to(Vector2.RIGHT)-target_direction.angle_to(Vector2.RIGHT)) < 90:
				closest = target
	return closest
