extends Node2D

signal restart

const enemyScene = preload("res://enemy.tscn")

var gameOver = false
var score = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Player.connect("playerTakeDamage", _on_player_take_damage)
	$Player.connect("abilityActivated", _on_player_ability_activated)
	$Player.connect("abilityDeactivated", _on_player_ability_deactivated)
	$Enemy.connect("enemyDied", _on_enemy_dead)
	$HUD/Health.text = "HP: " + str(5)
	$HUD/Score.text = "SCORE:" + str(0)
	$HUD/Ability.text = "Ability: INACTIVE"
	#GameOver text is hidden until player dies
	$GameOver.hide()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if gameOver and Input.is_action_just_released("enter"):
		print("rs game")
		gameOver = false
		get_tree().reload_current_scene()

func _on_player_take_damage(num: int) -> void:
	$HUD/Health.text = "HP: " + str(num)
	if (num <= 0):
		game_over()
	
func _on_enemy_dead() -> void:
	score += 5
	$HUD/Score.text = "SCORE:" + str(score)
	spawn_enemy()
	
func spawn_enemy() -> void:
	var enemy = enemyScene.instantiate()
	enemy.position = Vector2(640, 160)
	get_tree().current_scene.add_child(enemy)
	enemy.connect("enemyDied", _on_enemy_dead)
	
func _on_player_ability_activated() -> void:
	$HUD/Ability.text = "Ability: ACTIVE"
	
func _on_player_ability_deactivated() -> void:
	$HUD/Ability.text = "Ability: INACTIVE"
	
func game_over() -> void:
	$Player.queue_free()
	$GameOver.show()
	gameOver = true

	
