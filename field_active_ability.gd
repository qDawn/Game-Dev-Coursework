extends "res://Scripts/ability.gd"

const bulletScene = preload("res://Scenes/enemy_bullet.tscn")
const maxBullets = 5
const bulletAngularSpeed = TAU / 4
const bulletAngleOffset = TAU / maxBullets

var bullets = 0
var bulletAngle = 0

func _process(delta: float) -> void:
	bullets_movement(delta)

# Doesnt work
# Need player/enemy area2d to scale 
func ability(delta: float) -> void:
	for area in user.get_overlapping_areas():
		if area.is_in_group("player_bullet"):
			# player's bullet is added after removing enemy bullet
			if bullets < maxBullets:
				area.queue_free()
				bullets += 1
				var bullet = bulletScene.instantiate()
				user.add_child(bullet)
				bullet.connect("bulletDied", _on_bullet_dead)
				
				

func bullets_movement(delta: float) -> void:
	bulletAngle += bulletAngularSpeed * delta
	var angle = bulletAngle
	for child in user.get_children():
		if child.is_in_group("bullet"):
			print(child)
			child.position.x = (user.get_size().x * cos(angle))
			child.position.y = (user.get_size().y * sin(angle))
			angle += bulletAngleOffset 
			
func _on_bullet_dead() -> void:
	bullets = max(0, bullets - 1)
		
