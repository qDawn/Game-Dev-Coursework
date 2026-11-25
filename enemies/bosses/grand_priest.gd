extends "res://enemies/superclasses/enemy.gd"

const SMITE_AREA = preload("uid://ccyp3ra11vl6l")
const LASER = preload("uid://bqa3wjbpwh3yv")
const BASIC_BULLET = preload("uid://mq4hucp4nyfe")

func _ready() -> void:
	super()
	max_health = 500
	current_health = 500
	speed = 75
	min_range = 200
	attack_range = 1000
	attack_cooldown = 2.5
	damage = 10
	possessable = false
	
func _process(delta: float) -> void:
	super(delta)
	if not effects.has("silence") and state != "possessed" and state != "dead" and global_position.distance_to(target.global_position) < attack_range:
		#spawn_smites(3)
		shoot_bullets(10)
		take_effect.emit("silence", 1.5)

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
	
	
func spawn_smites(ring_count : int) -> void:
	spawn_smite(target.global_position)
	
	# Default radius of smite is 128
	var smite_gap = 256
	# Spawns a ring of smites around the target
	for i in range(1, ring_count):
		var circum = 2 * PI * smite_gap * i
		var smite_count = int(floor(circum / smite_gap))
		
		for j in range(0, smite_count):
			var angle : float = 2 * PI * j / smite_count
			var offset : Vector2 = Vector2(smite_gap * i * cos(angle), smite_gap * i * sin(angle))
			spawn_smite(target.global_position + offset)
					
		
func spawn_smite(pos : Vector2) -> void:
	var smite : Area2D = SMITE_AREA.instantiate()
	smite.attack_group = "ally"
	smite.global_position = pos
	get_tree().current_scene.add_child(smite)
	
func shoot_bullets(count : int) -> void:
	for i in range(-int(count/2), int(count/2)):
		var angle : float = PI * i / count
		var direction : Vector2 = global_position.direction_to(target.global_position).rotated(angle)
		shoot_bullet(direction)
		# Add homign bullets for harder difficulty
		
func shoot_bullet(direction : Vector2) -> void:
	var b = BASIC_BULLET.instantiate()
	b.global_position = $weapon/spr/origin.global_position
	b.direction = direction
	b.damage = 10
	b.speed = 150
	b.attacking_group = "ally"
	get_tree().current_scene.add_child(b)
	
