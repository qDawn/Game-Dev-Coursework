extends Area2D

signal enemyDied
const bulletScene = preload("res://enemy_bullet.tscn")
const speed = 250

var screenSize 
var randPos : Vector2
var random = RandomNumberGenerator.new()
var moving = false
var health = 100
var enemySize
var abilityOn = false
var extraBullets = 4


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	area_entered.connect(_on_area_entered)
	screenSize = get_viewport_rect().size
	enemySize = $CollisionShape2D.shape.get_rect().size
	$ShootTimer.timeout.connect(shoot_bullets)
	$MoveTimer.timeout.connect(new_randPos)
	$AbilityCooldownTimer.timeout.connect(ability)
	$AbilityActiveTimer.timeout.connect(set_abilityOn_false)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	movement(delta)	
	if health <= 0:
		die()
		

func movement(delta: float) -> void:
	# Enemy arrived at the chosen random location
	if moving and position.is_equal_approx(randPos):
		$MoveTimer.start()
		moving = false
	if moving:
		var direction : Vector2
		# calculates the direction that the enemy should move
		direction.x = randPos.x - position.x 
		direction.y = randPos.y - position.y
		
		# if enemy is close enough, change enemy position to the random location
		if direction.length() < 3:
			position = randPos
		else:
			position += direction.normalized() * delta * speed
		
	
		
func new_randPos() -> void:
	# Gets a random value inside the screen
	if moving:
		return
	randPos.x = randi_range(100, screenSize.x - 100)
	randPos.y = randi_range(100, screenSize.y / 2)
	moving = true
	
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
	if abilityOn:
		ability_shoot()
	else:
		# default shooting
		get_tree().current_scene.add_child(spawn_default_bullet())

func shoot_bullet(bullet) -> void:
	get_tree().current_scene.add_child(bullet)
	
func spawn_default_bullet():
	var bullet = bulletScene.instantiate()
	bullet.position.x = position.x
	bullet.position.y = position.y + enemySize.y / 2
	bullet.velocity = Vector2(0,1)
	return bullet
	
func ability_shoot() -> void:
	if not abilityOn:
		return

	for i in range(0, extraBullets + 1):
		var bullet = spawn_default_bullet()
		bullet.velocity = Vector2(-1 + (i * 2.0 / extraBullets), 1).normalized()
		shoot_bullet(bullet)
	
	
func ability() -> void:
	abilityOn = true
	$AbilityActiveTimer.start()

func set_abilityOn_false() -> void:
	abilityOn = false
	
