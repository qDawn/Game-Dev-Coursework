extends "res://Scripts/enemy.gd"

const ENEMY_BULLET = preload("uid://dpygu43fwffkp")
const SMITE_AREA = preload("uid://ccyp3ra11vl6l")
@export var bullet_speed : int
@export var bullet_damage : int 
@export var smite_damage : int
@export var smite_range : int
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super()
	max_health = 25
	current_health = 1
	#how fast it moves
	speed = 200
	#how close it gets to the player
	min_range = 500
	#how far it attacks from
	attack_range = 500
	#how far it can activate ability from
	smite_range = 700
	#how fast it can attack
	attack_speed = 10
	#how fast its projectiles move
	bullet_speed = 500
	#how much damage the projectiles do
	bullet_damage = 3
	#how much damage the smite ability does
	smite_damage = 15
	$cast_timer.timeout.connect(spawn_smite)
	
	
func _process(delta : float) -> void:
	super(delta)
	
	if state == 'alive':
		var distance: float = global_position.distance_to(get_tree().get_first_node_in_group('player').global_position)
		if distance <= smite_range and not ability_cooldown:
			_on_ability()
			
func _on_attack(direction: Vector2):
	if not attack_cooldown:
		var b: Area2D = ENEMY_BULLET.instantiate()
		b.global_position = $weapon/spr/origin.global_position
		b.direction = direction
		b.damage = damage
		b.speed = bullet_speed
		if state == 'possessed': b.remove_from_group("enemy_bullet"); b.add_to_group("player_bullet")
		get_tree().current_scene.add_child(b)
		attack_cooldown = true
		$attack_cooldown.start()
		
func _on_ability() -> void:
	if not ability_cooldown:
		#Start casting the smite
		$cast_timer.start()
		$ability_cooldown.start()
		can_move = false
		ability_cooldown = true
		
func spawn_smite() -> void:
	var smite: Area2D = SMITE_AREA.instantiate()
	if state != 'possessed':
		smite.global_position = get_tree().get_first_node_in_group('player').global_position
	else:
		smite.global_position = get_global_mouse_position()
		
	can_move = true
	get_tree().current_scene.add_child(smite)
	smite.get_node("timer").timeout.connect(_on_smite.bind(smite))
	
		
func _on_smite(smite : Area2D) -> void:
	var attack_group : String
	if state == 'possessed' : attack_group = 'enemy'
	else : attack_group = 'player'
	for body in smite.get_overlapping_bodies():
		if body.is_in_group(attack_group):
			body.emit_signal('take_damage', smite_damage)
		
	smite.queue_free()
