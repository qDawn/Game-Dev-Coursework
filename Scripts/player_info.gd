extends Node

##This is a global script. EVERYTHING in the scene can access it.
var max_health: int = 3
var current_health: int = 3
var score: int = 0


##Method to get the player's direction according to the input
func get_player_direction() -> Vector2:
	var direction: Vector2 = Vector2.ZERO
	#horizontal movement
	if Input.is_action_pressed("move_right"): direction.x += 1
	elif Input.is_action_pressed("move_left"): direction.x -= 1
	#vertical movement
	if Input.is_action_pressed("move_up"): direction.y -= 1
	elif Input.is_action_pressed("move_down"): direction.y += 1
	return direction
