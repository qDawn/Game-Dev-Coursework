extends Node2D

signal gameover

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
	"suicide_bomber": 100,
	"bomber": 125,
}

#test case should delete when all enemies finalised
const DEFAULT_KILL_POINTS: int = 50

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	connect("gameover",_on_gameover)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	#PlayerInfo.score += POINTS_PER_SECOND
	pass

func _on_gameover() -> void:
	get_tree().call_deferred("change_scene_to_file","res://menus/death_menu.tscn")

func get_kill_points(enemy_name: String) -> int:
	return KILL_POINTS.get(enemy_name, DEFAULT_KILL_POINTS)

func get_wave_points(wave_number: int) -> int:
	return WAVE_BASE_POINTS + WAVE_BONUS_POINT_PER_WAVE * wave_number
