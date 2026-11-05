extends "res://Scripts/enemy.gd"

const ENEMY_BULLET = preload("uid://dpygu43fwffkp")

@export var bullet_speed: int = 700

var burst_total: int = 3
var burst_left: int = 0
var burst_direction: Vector2 = Vector2.ZERO
var burst_timer: Timer

func _ready() -> void:
	super()
	max_health = 20
	current_health = 20
	speed = 220
	min_range = 160
	attack_range = 340
	attack_cooldown = 2
	bullet_speed = 700
	damage = 3

	# Pause after the last bullet of a burst. attack_speed on enemy.gd is never read.
	$attack_cooldown.wait_time = 1.4

	burst_timer = Timer.new()
	burst_timer.wait_time = 0.1
	burst_timer.timeout.connect(_on_burst_timer_timeout)
	add_child(burst_timer)

func _on_attack(direction: Vector2) -> void:
	# enemy.gd emits attack every frame while the player is in range.
	# Possessed bodies also get attack every frame while the mouse is held.
	# Leave immediately once a burst has started.
	if $attack_cooldown.is_stopped():
		return
	burst_direction = direction
	burst_left = burst_total
	_fire_burst_shot()
	burst_timer.start()
	super(direction)

func _fire_burst_shot() -> void:
	var bullet: Area2D = ENEMY_BULLET.instantiate()
	bullet.global_position = $weapon/spr/origin.global_position
	bullet.direction = burst_direction.rotated(randf_range(-0.06, 0.06))
	bullet.damage = damage
	bullet.speed = bullet_speed
	if state == "possessed":
		bullet.remove_from_group("enemy_bullet")
		bullet.add_to_group("player_bullet")
	get_tree().current_scene.add_child(bullet)
	burst_left -= 1

func _on_burst_timer_timeout() -> void:
	if state == "dead" or burst_left <= 0:
		_end_burst()
		return
	if state == "alive":
		var player := get_tree().get_first_node_in_group("player")
		if player:
			burst_direction = global_position.direction_to(player.global_position)
	elif state == "possessed":
		burst_direction = global_position.direction_to(get_global_mouse_position())
	_fire_burst_shot()
	if burst_left <= 0:
		_end_burst()

func _end_burst() -> void:
	burst_timer.stop()
	burst_left = 0
	# Start the inherited cooldown only after the last shot.
	# Starting it on the first shot lets _on_attack_cooldown_timeout
	# clear attack_cooldown while bullets are still coming out,
	# and enemy.gd will open a second burst on top of this one.
	$attack_cooldown.start()
