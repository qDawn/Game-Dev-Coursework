extends "res://projectiles/basic_bullet.gd"


func _physics_process(delta: float) -> void:
	super(delta)
	if not $follow_timer.is_stopped():
		var direction_to_target: Vector2 = global_position.direction_to(seek_closest_target().global_position)
		direction = (direction+direction_to_target/2)/2

func seek_closest_target() -> Node2D:
	var closest: Node2D = null
	for target: Node2D in get_tree().get_nodes_in_group(attacking_group):
		if not closest or global_position.distance_to(target.global_position) < global_position.distance_to(closest.global_position):
			closest = target
	return closest
