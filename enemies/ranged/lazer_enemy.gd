extends "res://enemies/superclasses/enemy.gd"

const LAZER = preload("uid://bqa3wjbpwh3yv")
var prime_time: float = 1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super()
	max_health = 25
	current_health = 25
	#how fast it moves
	speed = 200
	#how close it gets to the player
	min_range = 200
	#how far it attacks from
	attack_range = 300
	#how fast it can attack
	attack_cooldown = 2
	#damage
	damage = 6

func _on_attack(direction: Vector2) -> bool:
	if not super(direction): return false

	var space_state = get_world_2d().direct_space_state
	var start: Vector2 = $weapon/spr/origin.global_position
	var end: Vector2 = start + direction*9999
	var query = PhysicsRayQueryParameters2D.create(start, end)
	query.collision_mask = 8
	var result: Dictionary = space_state.intersect_ray(query)
	if result:
		var l: Node2D = LAZER.instantiate()
		if state == "possessed": 
			l.target_group = "enemy"
		else: 
			l.target_group = "ally"  
		l.damage = damage
		
		get_tree().root.add_child(l)
		l.emit_signal("setup",prime_time, start, result.position, 20)
	_on_take_effect('stun',prime_time*2)
	return true

func _on_possession() -> void:
	super()
	prime_time = 0.5
