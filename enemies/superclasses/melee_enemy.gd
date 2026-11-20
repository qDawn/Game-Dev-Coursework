extends "res://enemies/superclasses/enemy.gd"

signal attack_end

var already_hit: Array[Node2D] = []
var swing_speed: float = 0.1
var direction_multiplier: float = 1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super()
	connect("attack_end", _on_attack_end)

func _on_attack(direction: Vector2) -> bool:
	if not super(direction): return false
	attacking = true
	var direction_angle: float = 180*direction.angle()/PI
	direction_multiplier *= -1

	#swinging the weapon
	$weapon.rotation_degrees -= direction_multiplier*70
	#tween for swinging
	var tween_swing: Tween = get_tree().create_tween()
	tween_swing.tween_property($weapon, "rotation_degrees", direction_angle+direction_multiplier*70, swing_speed)
	tween_swing.tween_callback(func(): emit_signal("attack_end"); attacking = false)
	#weapon collison
	$weapon_collision.rotation_degrees = direction_angle
	
	#clear the array of entities hit
	already_hit.clear()
	return true
	
func _physics_process(delta: float) -> void:
	super(delta)
	handle_weapon_collision()
		
func handle_weapon_collision(weapon_area : Area2D = $weapon_collision/melee_collision_area) -> void:
	if !attacking: return
	for body in weapon_area.get_overlapping_bodies():
		if body in already_hit: continue #if the entity has already taken damage.
		already_hit.append(body)
		#deal damage
		if attacking:
			if is_in_group('ally') and body.is_in_group('enemy') or is_in_group('enemy') and body.is_in_group('ally'):
				body.emit_signal('take_damage', damage)

func _on_attack_end():
	pass
