extends Node

const spread_shooter = preload("uid://qc8o7a1cf37q")
const basic_shooter = preload("uid://daux7s6ck68f2")

const enemies = {"basic_shooter": {"scene": basic_shooter, "weight": 1}, 
				"spread_shooter": {"scene": spread_shooter, "weight": 3}}
				
var wave_end : bool = true
var wave : int= 1
# Each wave gets harder as more weight of enemies can spawn
var wave_scale : int = 5
#Restricts certain enemies in earlier waves by limiting the weight an enemy can have
var max_enemy_weight_wave_ratio : float = 0.3

var min_enemy_spawn_distance : int = 500
var max_enemy_spawn_distance  : int= 3000
var enemies_alive : int = 0

var rng = RandomNumberGenerator.new()
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if wave_end:
		wave_end = false
		generate_enemies()

func generate_enemies() -> void:
	var max_weight : int = wave * wave_scale
	var total_weight : int = 0
	while total_weight < max_weight:
	
		# gets a random key from enemies
		var random_enemy : String = enemies.keys().pick_random()
		# Reject random enemy if the weight is too large. 
		var weight = enemies[random_enemy]["weight"]
		if weight >= max_weight * max_enemy_weight_wave_ratio:
			continue
		
		total_weight += weight
		spawn_enemy(random_enemy)
		
func spawn_enemy(enemy_name : String) -> void:
	var enemy = enemies[enemy_name]["scene"].instantiate()
	enemy.global_position = get_valid_enemy_spawn_position()
	
	add_child(enemy)
		
		
func get_valid_enemy_spawn_position() -> Vector2:
	var player_position = get_parent().get_node("Player").global_position
	
	var x : int = rng.randi_range(0, max_enemy_spawn_distance) - max_enemy_spawn_distance / 2
	var y : int = rng.randi_range(0, max_enemy_spawn_distance) - max_enemy_spawn_distance / 2
	player_position.x += x
	player_position.y += y
	return player_position
	
func _on_enemy_died():
	enemies_alive -= 1
	if enemies_alive <= 0:
		wave_end = true
