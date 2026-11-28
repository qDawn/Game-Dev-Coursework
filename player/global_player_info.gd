extends Node

##This is a global script. EVERYTHING in the scene can access it.
const max_health: float = 4
var current_health: float = max_health
var possession_target: Enemy = null

var score: int = 0
var wave: int = 1
var difficulty : float = 1

## Enemies that spawned during the current run. Scene filenames, e.g. "bomber", so when viewing in compendium can maybe just append .tscn
var seen_this_run: Array[String] = []
## Every enemy seen in any run this session. Not written to disk yet.
var discovered: Array[String] = []

func mark_enemy_seen(enemy_name: String) -> void:
	if enemy_name == "" or enemy_name in seen_this_run:
		return
	seen_this_run.append(enemy_name)

#Add seen enemies to discovered and reset for a new run
func keep_seen_enemies() -> void:
	for enemy_name in seen_this_run:
		if enemy_name not in discovered:
			discovered.append(enemy_name)
	seen_this_run.clear()

func take_damage(amount: float) -> void:
	current_health = max(current_health - amount, 0)

func add_score(amount: int) -> void:
	score += amount

func start_new_run() -> void:
	keep_seen_enemies()
	current_health = max_health
	score = 0
	wave = 1
	
##Method to get the player's direction according to the input
func get_player_direction() -> Vector2:
	var direction: Vector2 = Vector2.ZERO
	#horizontal movement
	if Input.is_action_pressed("move_right"): direction.x += 1
	elif Input.is_action_pressed("move_left"): direction.x -= 1
	#vertical movement
	if Input.is_action_pressed("move_up"): direction.y -= 1
	elif Input.is_action_pressed("move_down"): direction.y += 1
	return direction.normalized()
