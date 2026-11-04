extends "res://Scripts/enemy.gd"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super()
	max_health = 35
	current_health = 35
	#how fast it moves
	speed = 250
	#how close it gets to the player
	min_range = 60
	#how far it attacks from
	attack_range = 150
	#how fast it can attack
	attack_speed = 10
	#damage
	damage = 10

func _on_attack(direction: Vector2):
	if not attack_cooldown:
		attacking = true
		var direction_angle: float = 180*direction.angle()/PI
		var direction_multiplier = 1 if (-90 <= direction_angle and direction_angle  <= 90) else -1

		#swinging the weapon
		$weapon.rotation_degrees -= direction_multiplier*80
		#tween for swinging
		var tween_swing: Tween = get_tree().create_tween()
		tween_swing.tween_property($weapon, "rotation_degrees", direction_angle+direction_multiplier*80, 0.1)
		tween_swing.tween_property($'.', "attacking", false, 0)
		#tween for extending
		var tween_extend: Tween = get_tree().create_tween()
		tween_extend.tween_property($weapon/spr, "position", Vector2(64,0), 0.1)
		tween_extend.tween_property($weapon/spr, "position", Vector2(32,0), 0)
		
		#weapon collison
		$weapon_collision.rotation_degrees = direction_angle
		
		attack_cooldown = true
		$attack_cooldown.start()

func _process(delta: float) -> void:
	super(delta)
	if attacking:
		for body in $weapon_collision/melee_collision_area.get_overlapping_bodies():
			#dealing damage
			if attacking and (state == 'possessed' and body.is_in_group('enemy') or state != 'possessed' and body.is_in_group('player')):
				body.emit_signal('take_damage', damage)
		for area in $weapon_collision/melee_collision_area.get_overlapping_areas():
			#destroy bullets
			if attacking and state == 'possessed' and area.is_in_group('enemy_bullet'):
				area.queue_free()
