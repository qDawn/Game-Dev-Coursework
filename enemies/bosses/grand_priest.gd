extends "res://enemies/superclasses/enemy.gd"

const SMITE_AREA = preload("uid://ccyp3ra11vl6l")
const LASER = preload("uid://bqa3wjbpwh3yv")
const BASIC_BULLET = preload("uid://mq4hucp4nyfe")

var difficulty : float = 1
func _ready() -> void:
	super()
	max_health = 300 * difficulty
	current_health = max_health
	speed = 70
	min_range = 300
	attack_range = 1000
	attack_cooldown = 1
	damage = 10
	possessable = false
	$ability_cooldown.wait_time = 10
	ability_duration = min(5 * difficulty, 7)
	
func _process(delta: float) -> void:
	super(delta)
	if not effects.has("silence") and state != "possessed" and state != "dead" and global_position.distance_to(target.global_position) < attack_range:
		#spawn_smites(3)
		pass
	_on_ability()
	

func _on_attack(direction: Vector2) -> bool:
	if !$ability_active.is_stopped(): return false
	if super(direction):
		print("Attack")
		shoot_bullets(5, 200, 250)
	return true
func _on_ability() -> bool:
	if super():
		var rand = randi_range(1,3) # 6 ability patterns
		#Continues using an ability pattern until ability timer is off
		while !$ability_active.is_stopped():
			match rand:
				1:
					await spawn_smites(3, 256)
				2:
					await bullet_pattern_1()
				3:
					await bullet_pattern_2()
					
			await get_tree().create_timer(1).timeout
		return true
	return false
	
func _on_ability_cooldown_timeout() -> void:
	pass
	
func spawn_lasers(count : int):
	for i in range(0, count):
		var angle : float = 2 * PI * i / count
		var direction : Vector2 = global_position.direction_to(target.global_position).rotated(angle)
		spawn_laser(direction)
	_on_take_effect('stun',1*2)
	
func spawn_laser(direction : Vector2):
	var space_state = get_world_2d().direct_space_state
	var start: Vector2 = $weapon/spr/origin.global_position 

	var end: Vector2 = start + direction*9999
	var query = PhysicsRayQueryParameters2D.create(start, end)
	query.collision_mask = 8
	var result: Dictionary = space_state.intersect_ray(query)
	if result:
		var l: Node2D = LASER.instantiate()
		l.target_group = "ally"  
		l.damage = 10
		
		add_child(l)
		l.emit_signal("setup",1, start, result.position, 20)
	
	
func spawn_smites(ring_count : int, smite_gap : int) -> void:
	var pos : Vector2 = target.global_position
	spawn_smite(pos)
	# Default radius of smite is 128
	
	# Spawns a ring of smites around the target
	for i in range(1, ring_count):
		var circum = 2 * PI * smite_gap * i
		var smite_count = int(floor(circum / smite_gap))
		
		for j in range(0, smite_count):
			var angle : float = 2 * PI * j / smite_count
			var offset : Vector2 = Vector2(smite_gap * i * cos(angle), smite_gap * i * sin(angle))
			spawn_smite(pos + offset)
		await get_tree().create_timer(0.3).timeout
	await get_tree().create_timer(1.5).timeout	
		
func spawn_smite(pos : Vector2) -> void:
	var smite : Area2D = SMITE_AREA.instantiate()
	smite.attack_group = "ally"
	smite.global_position = pos
	get_tree().current_scene.add_child(smite)
	
func bullet_pattern_1() -> void:
	# make new bullet that lasts longer and is smaller
	shoot_bullets(10, 130, 160)
	await get_tree().create_timer(1).timeout
	shoot_bullets(10, 110, 120)
	
func bullet_pattern_2() -> void:
	shoot_bullets(7, 140, 160)
	await get_tree().create_timer(1).timeout
	shoot_bullets(5, 185, 195)
	
func shoot_bullets(count : int, min_speed: int, max_speed: int) -> void:
	for i in range(-ceil(count/2.0), floor(count/2.0)):
		var angle : float = PI * i / count
		var direction : Vector2 = global_position.direction_to(target.global_position).rotated(angle)
		var bullet_speed = randi_range(min_speed, max_speed) * difficulty
		shoot_basic_bullet(direction, bullet_speed)


func shoot_basic_bullet(direction : Vector2, speed : int) -> void:
	var b = BASIC_BULLET.instantiate()
	b.global_position = $weapon/spr/origin.global_position
	b.direction = direction
	b.damage = 10
	b.speed = speed
	b.attacking_group = "ally"
	get_tree().current_scene.add_child(b)
	
