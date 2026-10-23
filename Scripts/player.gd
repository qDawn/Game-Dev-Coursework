extends CharacterBody2D

signal playerTakeDamage
signal abilityActivated
signal abilityDeactivated

const bulletScene = preload("res://player_bullet.tscn")
const SPEED = 500
const bulletAngularSpeed = TAU / 4
const bulletAngleOffset = TAU / maxAbilityBullet
const shootDelayVal = 10
const maxAbilityBullet = 5

var screen_size
var player_size
var health = 5
var invincibility = false
var abilityAvailable = true
var abilityOn = false
var abilityBullet = 0 
var shootDelay = shootDelayVal
var bulletAngle = 0

var possessedAbility

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	screen_size = get_viewport_rect().size
	player_size = $Area2D/CollisionShape2D.shape.get_rect().size
	$Area2D.area_entered.connect(_on_attack_body_entered)
	$InvincTimer.timeout.connect(set_invincibility_false)
	$AbilityCooldownTimer.timeout.connect(set_abilityAvailable_true)
	$AbilityActiveTimer.timeout.connect(set_abilityOn_false)


func _physics_process(delta: float) -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	movement(delta)
	ability()
	bullets_movement(delta)
	if colliding_enemies() or colliding_bullets():
		take_damage()
		
		
func movement(delta: float) -> void:
	var velocity = Vector2.ZERO
	if Input.is_action_pressed("move_right"):
		velocity.x +=1
	if Input.is_action_pressed("move_left"):
		velocity.x -=1
	if Input.is_action_pressed("move_up"):
		velocity.y -=1
	if Input.is_action_pressed("move_down"):
		velocity.y +=1
		
	
	position += velocity * delta * SPEED
	# Prevents the player's collision hitbox from exiting the screen.
	if position.x - player_size.x / 2 <= 0:
		position.x = 0 + player_size.x / 2
	if position.x + player_size.x / 2 >= screen_size.x:
		position.x = screen_size.x - player_size.x / 2
	if position.y - player_size.y / 2 <= 0:
		position.y = 0 + player_size.y / 2
	if position.y + player_size.y / 2 >= screen_size.y:
		position.y = screen_size.y - player_size.y / 2
	
func get_size() -> Vector2:
	return player_size
	
func take_damage() -> void:
	health = max(0, health - 1)
	emit_signal("playerTakeDamage", health)
	
func _on_attack_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemy"):
		body.take_damage(5)
	
func colliding_enemies() -> bool:
	if invincibility:
		return false
	for area in $Area2D.get_overlapping_areas():
		if area.is_in_group("enemy"):
			invincibility = true
			$InvincTimer.start()
			return true
	return false
	
func colliding_bullets() -> bool:
	if invincibility:
		return false
	for area in $Area2D.get_overlapping_areas():
		if area.is_in_group("enemy_bullet"):
			invincibility = true
			$InvincTimer.start()
			return true
	return false
	
	
func ability() -> void:
	
	if abilityAvailable and Input.is_action_pressed("enter"):
		abilityOn = true
		$AbilityActiveTimer.start()
		abilityActivated.emit()
		
	if not abilityOn:
		return
	abilityAvailable = false
	for area in $AbilityArea.get_overlapping_areas():
		if area.is_in_group("enemy_bullet"):
			# player's bullet is added after removing enemy bullet
			if abilityBullet < maxAbilityBullet:
				area.queue_free()
				abilityBullet += 1
				var bullet = bulletScene.instantiate()
				add_child(bullet)
				bullet.connect("bulletDied", _on_bullet_dead)
		
		
			
func bullets_movement(delta: float) -> void:
	bulletAngle += bulletAngularSpeed * delta
	var angle = bulletAngle
	for child in get_children():
		if child.is_in_group("player_bullet"):
			child.position.x = (player_size.x * cos(angle))
			child.position.y = (player_size.y * sin(angle))
			angle += bulletAngleOffset 
	
func set_invincibility_false() -> void:
	invincibility = false
	
func set_abilityAvailable_true() -> void:
	abilityAvailable = true
	
func set_abilityOn_false() -> void:
	abilityOn = false
	$AbilityActiveTimer.stop()
	abilityDeactivated.emit()
	
func _on_bullet_dead() -> void:
	abilityBullet = max(0, abilityBullet - 1)
