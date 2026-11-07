extends Timer

const SPREAD_SHOOTER = preload("uid://c0x624xsja20d")
const SNIPER_SHOOTER = preload("uid://bji3srgvip7ib")
const BASIC_SHOOTER = preload("uid://n16anm4mbvgt")
const MELEE_ENEMY = preload("uid://cctu3opvidee6")
const SMITE_ENEMY = preload("uid://b7fvihjufnxxq")
const SMG_SHOOTER = preload("uid://b2w4alq8aeaio")
const KATANA_ENEMY = preload("uid://bcbyxbm1txx8i")
const HAMMER_ENEMY = preload("uid://cps8a5ofc76u7")
const LAZER_ENEMY = preload("uid://cnrhv5s1314sc")


const enemies: Array[Dictionary] = [#{"resource": BASIC_SHOOTER, "weight": 1},
									#{"resource": SNIPER_SHOOTER, "weight": 2},
									#{"resource": SPREAD_SHOOTER, "weight": 2},
									#{"resource": MELEE_ENEMY, "weight": 1},
									#{"resource": SMITE_ENEMY, "weight": 3},
									#{"resource": SMG_SHOOTER, "weight": 1},
									#{"resource": KATANA_ENEMY, "weight": 2},
									#{"resource": HAMMER_ENEMY, "weight": 4},
									{"resource": LAZER_ENEMY, "weight": 1}
									]

#Restricts certain enemies in earlier waves by limiting the weight an enemy can have
var max_enemy_weight_wave_ratio : float = 0.3

# Distance from player to enemy
var min_enemy_spawn_distance : int = 500
var max_enemy_spawn_distance  : int= 1000

var rng : RandomNumberGenerator = RandomNumberGenerator.new()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#3 second buffer before starting to spawn
	start(3)
	PlayerInfo.run_active = true

##Method for determining what types of enemies to spawn
func generate_enemies() -> void:
	var max_weight : int = 3 + int(PlayerInfo.wave/2.0)
	var total_weight : int = 0
	while total_weight < max_weight:
		# gets a random key from enemies
		var random_enemy: Dictionary = enemies.pick_random()
		var weight : int = random_enemy["weight"]
		if weight + total_weight > max_weight: continue
		total_weight += weight
		spawn_enemy(random_enemy["resource"])

#method for spawning enemies
func spawn_enemy(enemy_resource : Resource) -> void:
	var enemy = enemy_resource.instantiate()
	enemy.global_position = get_valid_enemy_spawn_position()
	add_child(enemy)
		
##method for getting a valid coord to spawn an enemy
func get_valid_enemy_spawn_position() -> Vector2:
	var player_position : Vector2 = get_parent().get_node("Player").global_position
	var enemy_position :Vector2 = player_position
	var distance : float = enemy_position.distance_to(player_position)
	
	while distance < min_enemy_spawn_distance or distance > max_enemy_spawn_distance or enemy_position.y <= -600 or enemy_position.y >= 640 or enemy_position.x <= -1520 or enemy_position.x >= 1950:
		enemy_position = player_position
		enemy_position.x +=  rng.randi_range(0, max_enemy_spawn_distance) - max_enemy_spawn_distance / 2.0
		enemy_position.y += rng.randi_range(0, max_enemy_spawn_distance) - max_enemy_spawn_distance / 2.0
		distance = enemy_position.distance_to(player_position)

	return enemy_position
	
func _on_timeout() -> void:
	PlayerInfo.wave += 1
	var completed_wave: int = PlayerInfo.wave - 2
	if completed_wave >= 1:
		PlayerInfo.add_score(PlayerInfo.get_wave_points(completed_wave))
	generate_enemies()
	start(15)
