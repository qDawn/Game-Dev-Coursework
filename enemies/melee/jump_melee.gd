extends "res://enemies/superclasses/melee_enemy.gd"

var ability_damage_bonus: float = 2

func _ready() -> void:
	super()
	max_health = 30
	current_health = 30
	speed = 250
	min_range = 50
	attack_range = 150
	damage = 5
	attack_cooldown = 1
	ability_duration = 1

func _process(delta: float) -> void:
	super(delta)
	if not state == "possessed" and not state == "dead" and global_position.distance_to(target.global_position) > attack_range:
		_on_ability()

func _on_attack(direction: Vector2) -> bool:
	if not $ability_active.is_stopped(): return false
	return super(direction)

func _on_ability() -> bool:
	if not super(): return false
	speed *= 1.2
	
	$weapon.visible = false
	#sprite tween
	var leap_tween: Tween = create_tween()
	leap_tween.tween_property($sprite,"position:y",-200,ability_duration*3/4)
	leap_tween.tween_property($sprite,"position:y",0,ability_duration/4)
	
	#area tween
	var area_indication_tween: Tween = create_tween()
	area_indication_tween.tween_property($aoe/Sprite2D,"self_modulate:a",0.5,ability_duration)
	area_indication_tween.tween_property($aoe/Sprite2D,"self_modulate:a",0,0.2)
	$ability_active.start()
	
	#invulnerability
	set_collision_layer_value(1,false)
	set_collision_mask_value(1,false)
	
	return true

func _on_ability_active_timeout() -> void:
	super()
	_on_take_effect("stun",0.5)
	speed /= 1.2
	for body in $aoe.get_overlapping_bodies():
		if body.is_in_group("ally") and is_in_group("enemy") or body.is_in_group("enemy") and is_in_group("ally"):
			body.emit_signal("take_damage", damage + ability_damage_bonus)
			body.emit_signal("take_effect","stun",1)
	for area: Area2D in $aoe.get_overlapping_areas():
		if area.is_in_group("projectile"):
			area.queue_free()

	#reset visibility
	$weapon.visible = true
	set_collision_layer_value(1,true)
	set_collision_mask_value(1,true)
