extends Area2D

signal enemyDied
const bulletScene = preload("res://Scenes/enemy_bullet.tscn")


var screenSize 
var randPos : Vector2
var random = RandomNumberGenerator.new()
var state = "idle"
var health = 100
var speed = 250
var enemySize
var abilityOn = false


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	area_entered.connect(_on_area_entered)
	screenSize = get_viewport_rect().size
	$ShootTimer.timeout.connect(shoot_bullets)
	#$MoveTimer.timeout.connect(new_randPos)
	enemySize = $CollisionShape2D.shape.get_rect().size

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	movement(delta)	
	if health <= 0:
		die()
		
func get_size():
	return enemySize

func movement(delta: float) -> void:
	# Enemy arrived at random location
	if state == "move" and position.is_equal_approx(randPos):
		$MoveTimer.start()
		state = "idle"
	if state == "move":
		var direction : Vector2
		# calculates the direction that the enemy should move
		direction.x = randPos.x - position.x 
		direction.y = randPos.y - position.y
		
		if direction.length() < 3:
			position = randPos
		position += direction.normalized() * delta * speed
		
	
		
func new_randPos() -> void:
	if state == "move":
		return
	randPos.x = randi_range(100, screenSize.x - 100)
	randPos.y = randi_range(100, screenSize.y / 2)
	state = "move"
	
func _on_area_entered(body: Node2D) -> void:
	if body.is_in_group("player_bullet"):
		take_damage(10)
	
func take_damage(num: int) -> void:
	health -= num
	print(health)
	
func die() -> void:
	hide()
	enemyDied.emit()
	print("enemy died")
	queue_free()

func shoot_bullets() -> void:
	get_tree().current_scene.add_child(spawn_default_bullet())

func shoot_bullet(bullet) -> void:
	get_tree().current_scene.add_child(bullet)
	
func spawn_default_bullet():
	var bullet = bulletScene.instantiate()
	bullet.position.x = position.x
	bullet.position.y = position.y + enemySize.y / 2
	bullet.velocity = Vector2(0,1)
	return bullet
	

	

	
