extends Node

##This is a global script. EVERYTHING in the scene can access it.
signal health_changed
signal score_changed
signal player_died


var max_health = 3
var current_health = 3
var score = 0

func take_damage(amount: int) -> void:
	current_health = maxi(current_health - amount, 0)
	health_changed.emit()
	if current_health ==0:
		player_died.emit()

func add_score(amount: int) -> void:
	score += amount
	score_changed.emit()
	
func start_new_run() -> void:
	current_health = max_health
	score = 0
	health_changed.emit()
	score_changed.emit()

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
