extends "res://enemies/superclasses/enemy.gd"

const SMITE_AREA = preload("uid://ccyp3ra11vl6l")
const LASER = preload("uid://bqa3wjbpwh3yv")
const BASIC_BULLET = preload("uid://mq4hucp4nyfe")

var ability_on : bool = false
var min_long_attack_range : int = 600
func _ready() -> void:
	super()
	difficulty = PlayerInfo.difficulty
	max_health = 300 * difficulty
	current_health = max_health
	speed = 70 * difficulty
	min_range = 300
	attack_range = 1000
	attack_cooldown = 1
	damage = 10
	possessable = false
	$ability_cooldown.wait_time = 10
	ability_duration = min(5 * difficulty, 7)
	
func _process(delta: float) -> void:
	super(delta)
	if global_position.distance_to(target.global_position) < attack_range:
		_on_ability()
	

func _on_attack(direction: Vector2) -> bool:
	if !$ability_active.is_stopped(): return false
	if !ability_on and super(direction):
		# Spawns smite on player if far away
		if global_position.distance_to(target.global_position) > min_long_attack_range:
			spawn_smite(target.global_position)
		shoot_bullets(5, 200, 250)
	return true
	
func _on_ability() -> bool:
	if super():
		ability_on = true
		var rand = randi_range(1,1) # 5 ability patterns
		while !$ability_active.is_stopped():
			var smite_gap : int = max(256,320 / difficulty)
			match rand:
				1:
					await smite_pattern_1(min(5,round(3*difficulty)), smite_gap)
				2:
					await bullet_pattern_1()
				3:
					await bullet_pattern_2()
				4:
					await smite_pattern_2(5, 256)
				5:
					await spawn_lasers(11)
					shoot_bullets(9, 200, 220)
					
			await wait(0.5)
		ability_on = false
		return true
	return false
	

func spawn_lasers(count : int):
	var laser_delay : float = 0.03
	_on_take_effect('stun',laser_delay*count + 1)
	var direction : Vector2 = global_position.direction_to(target.global_position)
	for i in range(0, count):
		var angle : float = 2 * PI * i / count
		spawn_laser(direction.rotated(angle))
		await wait(laser_delay)
	await wait(0.25)
	
func spawn_laser(direction : Vector2):
	var space_state = get_world_2d().direct_space_state
	var start: Vector2 = global_position 

	var end: Vector2 = start + direction*9999
	var query = PhysicsRayQueryParameters2D.create(start, end)
	query.collision_mask = 8
	var result: Dictionary = space_state.intersect_ray(query)
	if result:
		var l: Node2D = LASER.instantiate()
		l.target_group = "ally"  
		l.damage = 10
		
		get_tree().current_scene.add_child(l)
		l.emit_signal("setup",1, start, result.position, 20)
	
	
func smite_pattern_1(ring_count : int, smite_gap : int) -> void:
	# Spawns smites in rings that goes outwards
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
		await wait(0.25)
	await wait(1.5)
		
func smite_pattern_2(count : int, smite_gap : int) -> void:
	#Spawns a row of smites from above and below the player.
	var pos : Vector2 = target.global_position
	for i in range(-ceil(count/2.0), floor(count/2.0)):
		for j in range(-3,3):
			var offset : Vector2 = Vector2(j*smite_gap, i*smite_gap)
			spawn_smite(pos + offset)
		await wait(0.2)
		
	await wait(0.7)
	pos  = target.global_position
	for i in range(-ceil(count/2.0), floor(count/2.0)):
		for j in range(-3,3):
			var offset : Vector2 = Vector2(j*smite_gap, -i*smite_gap)
			spawn_smite(pos + offset)
		await wait(0.2)
	
		
func spawn_smite(pos : Vector2) -> void:
	var smite : Area2D = SMITE_AREA.instantiate()
	smite.attack_group = "ally"
	smite.global_position = pos
	get_tree().current_scene.add_child(smite)
	
func bullet_pattern_1() -> void:
	shoot_bullets(10, 130, 160)
	await wait(1)
	shoot_bullets(10, 110, 120)
	
func bullet_pattern_2() -> void:
	shoot_bullets(7, 140, 160)
	await wait(1)
	shoot_bullets(5, 185, 195)
	
func shoot_bullets(count : int, min_speed: int, max_speed: int) -> void:
	for i in range(-ceil(count/2.0), floor(count/2.0)):
		var angle : float = PI * i / count
		var direction : Vector2 = global_position.direction_to(target.global_position).rotated(angle)
		var bullet_speed = randi_range(min_speed, max_speed) * difficulty
		shoot_basic_bullet(direction, bullet_speed)


func shoot_basic_bullet(direction : Vector2, bullet_speed : int) -> void:
	var b = BASIC_BULLET.instantiate()
	b.expiry_time = 7
	b.global_position = $weapon/spr/origin.global_position
	b.direction = direction
	b.damage = 10
	b.speed = bullet_speed
	b.attacking_group = "ally"
	get_tree().current_scene.add_child(b)
	
func wait(time : float) -> void:
	await get_tree().create_timer(time).timeout
