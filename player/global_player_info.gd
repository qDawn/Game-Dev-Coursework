extends Node

##This is a global script. EVERYTHING in the scene can access it.
const max_health: float = 4
## Scoring points
const POINTS_PER_SECOND: int = 10

const WAVE_BASE_POINTS: int = 200
const WAVE_BONUS_POINT_PER_WAVE: int = 50

const KILL_POINTS: Dictionary = {
	"basic_shooter": 50,
	"melee_enemy": 50,
	"smg_shooter": 75,
	"spread_shooter": 100,
	"sniper_shooter": 100,
	"katana_enemy": 125,
	"smite_enemy": 200,
	"hammer_enemy": 250,
}
#test case should delete when all enemies finalised
const DEFAULT_KILL_POINTS: int = 50


var current_health: float = max_health
var possession_target: CharacterBody2D = null

var score: int = 0
var wave: int = 1
var run_active: bool = false
var time_alive: float = 0

func _process(delta: float) -> void:
	if not run_active: 
		return
	time_alive += delta 
	while time_alive >= 1:
		time_alive -= 1
		score += POINTS_PER_SECOND

func take_damage(amount: float) -> void:
	current_health = max(current_health - amount, 0)

func add_score(amount: int) -> void:
	if not run_active: return
	score += amount
	
func get_kill_points(enemy_name: String) -> int:
	return KILL_POINTS.get(enemy_name, DEFAULT_KILL_POINTS)

func get_wave_points(wave_number: int) -> int:
	return WAVE_BASE_POINTS + WAVE_BONUS_POINT_PER_WAVE * wave_number

func start_new_run() -> void:
	current_health = max_health
	score = 0
	wave = 1
	run_active = false
	time_alive = 0

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
