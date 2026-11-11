extends "res://enemies/superclasses/enemy.gd"

##how close to the player it needs to be to begin explosion timer
var trigger_range: float = 90
##seconds it takes to explode once triggered
var fuse_time: float = 0.4
##radius of the explosion
var blast_radius: float = 120
##fraction of players max hp it takes 
var player_damage_fraction: float = 0.5
##fraction of an enemy's max health the explosion removes
var enemy_damage_fraction: float = 0.5

##whether the fuse it lit
var fusing: bool = false
##set once it has exploded, so it can never explode twice
var exploded: bool = false
var fuse_timer: Timer

func _ready() -> void:
	super()
	max_health = 20
	current_health = 20
	speed = 220
	min_range = 0
	attack_range = 0
	possessable = false
	$weapon.hide()

	fuse_timer = Timer.new()
	fuse_timer.one_shot = true
	fuse_timer.timeout.connect(_explode)
	add_child(fuse_timer)

func _process(delta: float) -> void:
	super(delta)
	if state == 'alive' and target and not fusing and not effects.has("stun"):
		if global_position.distance_to(target.global_position) <= trigger_range:
			_start_fuse()
	if fusing:
		queue_redraw()

func _physics_process(delta: float) -> void:
	if fusing:
		velocity = Vector2.ZERO
		return
	super(delta)

func _on_attack(_direction: Vector2) -> bool:
	return false

func _on_take_damage(d: float) -> void:
	if exploded: return
	super(d)
	if state == 'dead':
		$corpse_timer.hide()
		_explode.call_deferred()

func _start_fuse() -> void:
	fusing = true
	fuse_timer.start(fuse_time)
	var tween_flash: Tween = create_tween().set_loops()
	tween_flash.tween_property($sprite, "self_modulate", Color(1, 0.3, 0.3), 0.1)
	tween_flash.tween_property($sprite, "self_modulate", Color(1, 1, 1), 0.1)

func _draw() -> void:
	if not fusing: return
	var progress: float = 1.0 - fuse_timer.time_left / fuse_time
	draw_circle(Vector2.ZERO, blast_radius, Color(1, 0.2, 0.1, 0.1 + 0.25 * progress))
	draw_arc(Vector2.ZERO, blast_radius, 0, TAU, 48, Color(1, 0.3, 0.1, 0.8), 2.0)

func _explode() -> void:
	if exploded or not is_inside_tree(): return
	exploded = true
	var origin: Vector2 = global_position
	var enemies_in_range: Array[Node] = get_tree().get_nodes_in_group("enemy")
	var allies_in_range: Array[Node] = get_tree().get_nodes_in_group("ally")
	_spawn_blast_effect()
	for enemy in enemies_in_range:
		if enemy == self or not is_instance_valid(enemy) or enemy.get("state") != "alive": continue
		if origin.distance_to(enemy.global_position) > blast_radius: continue
		enemy.emit_signal("take_damage", enemy.max_health * enemy_damage_fraction)
	for ally in allies_in_range:
		if not is_instance_valid(ally) or origin.distance_to(ally.global_position) > blast_radius: continue
		if ally.is_in_group("player"):
			if not PlayerInfo.possession_target:
				ally.take_percent_damage(player_damage_fraction)
		elif ally.get("max_health"):
			ally.emit_signal("take_damage", ally.max_health * enemy_damage_fraction)
	queue_free()


func _spawn_blast_effect() -> void:
	var points: PackedVector2Array = []
	for i in 32:
		points.append(Vector2.from_angle(TAU * i / 32.0) * blast_radius)
	var flash := Polygon2D.new()
	flash.polygon = points
	flash.color = Color(1, 0.5, 0.1, 0.7)
	get_tree().current_scene.add_child(flash)
	flash.global_position = global_position
	var tween_fade: Tween = flash.create_tween()
	tween_fade.tween_property(flash, "modulate:a", 0.0, 0.3)
	tween_fade.tween_callback(flash.queue_free)
