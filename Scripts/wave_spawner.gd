extends Timer

const spread_shooter = preload("uid://qc8o7a1cf37q")
const sniper_shooter = preload("uid://cjws8kflc031e")
const basic_shooter = preload("uid://daux7s6ck68f2")

const enemies = {"basic_shooter": {"scene": basic_shooter, "weight": 1},
				"sniper_shooter": {"scene": sniper_shooter, "weight": 2},
				"spread_shooter": {"scene": spread_shooter, "weight": 2}}

#Restricts certain enemies in earlier waves by limiting the weight an enemy can have
var max_enemy_weight_wave_ratio : float = 0.3

# Distance from player to enemy
var min_enemy_spawn_distance : int = 500
var max_enemy_spawn_distance  : int= 2000

var rng : RandomNumberGenerator = RandomNumberGenerator.new()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#3 second buffer before starting to spawn
	start(3)

##Method for determining what types of enemies to spawn
func generate_enemies() -> void:
	var max_weight : int = 3 + (PlayerInfo.wave/2.0)
	var total_weight : int = 0
	while total_weight < max_weight:
		# gets a random key from enemies
		var random_enemy : String = enemies.keys().pick_random()
		var weight : int = enemies[random_enemy]["weight"]
		if weight + total_weight > max_weight: continue
		total_weight += weight
		spawn_enemy(random_enemy)

#method for spawning enemies
func spawn_enemy(enemy_name : String) -> void:
	var enemy = enemies[enemy_name]["scene"].instantiate()
	enemy.global_position = get_valid_enemy_spawn_position()
	add_child(enemy)
		
##method for getting a valid coord to spawn an enemy
func get_valid_enemy_spawn_position() -> Vector2:
	var player_position : Vector2 = get_parent().get_node("Player").global_position
	var enemy_position :Vector2 = player_position
	var distance : float = enemy_position.distance_to(player_position)
	while distance < min_enemy_spawn_distance or distance > max_enemy_spawn_distance:
		enemy_position = player_position
		enemy_position.x +=  rng.randi_range(0, max_enemy_spawn_distance) - max_enemy_spawn_distance / 2
		enemy_position.y += rng.randi_range(0, max_enemy_spawn_distance) - max_enemy_spawn_distance / 2
		distance = enemy_position.distance_to(player_position)

	return enemy_position
	
func _on_timeout() -> void:
	PlayerInfo.wave += 1
	generate_enemies()
	#15 second stagnation between waves
	start(15)
