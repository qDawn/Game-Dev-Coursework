extends "res://enemies/superclasses/enemy.gd"

var already_hit: Array[Node2D] = []
var swing_speed: float = 0.1
var direction_multiplier: float = 1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super()

func _on_attack(direction: Vector2) -> bool:
	if not $ability_active.is_stopped(): return false
	if not super(direction): return false
	attacking = true
	var direction_angle: float = 180*direction.angle()/PI
	direction_multiplier *= -1

	#swinging the weapon
	$weapon.rotation_degrees -= direction_multiplier*70
	#tween for swinging
	var tween_swing: Tween = get_tree().create_tween()
	tween_swing.tween_property($weapon, "rotation_degrees", direction_angle+direction_multiplier*70, swing_speed)
	tween_swing.tween_property($'.', "attacking", false, 0)
	#weapon collison
	$weapon_collision.rotation_degrees = direction_angle
	
	#clear the array of entities hit
	already_hit.clear()
	return true

func _process(delta: float) -> void:
	super(delta)
	if attacking:
		for body in $weapon_collision/melee_collision_area.get_overlapping_bodies():
			if body in already_hit: continue #if the entity has already taken damage.
			already_hit.append(body)
			#deal damage
			if attacking and (state == 'possessed' and body.is_in_group('enemy') or state != 'possessed' and body.is_in_group('ally')):
				body.emit_signal('take_damage', damage)
		for area in $weapon_collision/melee_collision_area.get_overlapping_areas():
			#destroy bullets
			if attacking and state == 'possessed' and area.is_in_group('enemy_bullet'):
				area.queue_free()
