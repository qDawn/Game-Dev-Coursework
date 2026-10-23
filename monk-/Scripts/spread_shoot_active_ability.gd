extends "res://Scripts/ability.gd"

const bulletScene = preload("res://Scenes/enemy_bullet.tscn")

var shoot_ready = true
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super()
	$ShootTimer.timeout.connect(shoot_ready_true)


func _process(delta: float) -> void:
	super(delta)
	

func ability(delta: float) -> void:
	if shoot_ready:
		spread_shoot()
		shoot_ready = false

func shoot_bullet(bullet) -> void:
	get_tree().current_scene.add_child(bullet)
	
func spawn_default_bullet():
	var bullet = bulletScene.instantiate()
	bullet.position.x = user.position.x
	bullet.position.y = user.position.y + user.get_size().y / 2
	bullet.velocity = Vector2(0,1)
	return bullet
	
func spread_shoot() -> void:
	
	var extraBullets = 2
	for i in range(0, extraBullets + 1):
		var bullet = spawn_default_bullet()
		bullet.velocity = Vector2(-1 + (i * 2.0 / extraBullets), 1).normalized()
		shoot_bullet(bullet)
	#
func shoot_ready_true() -> void:
	shoot_ready = true
