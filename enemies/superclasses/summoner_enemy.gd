extends "res://enemies/superclasses/enemy.gd"


var minion_types: Array[Dictionary] = []
var summon_count: int = 2
var summon_interval: float = 6.0
var max_minions: int = 4
var cast_time: float = 0.6
var summon_distance: float = 60
var first_summon_delay: float = 2.0
var minions_possessable: bool = false
var ally_tint: Color = Color(0.6, 0.8, 1.0)

var minions: Array[Node2D] = []
var summon_clock: float = 0
var casting: bool = false

func _ready() -> void:
	super()
	summon_clock = summon_interval - first_summon_delay

func _physics_process(delta: float) -> void:
	if casting: return
	super(delta)
	if state != 'alive' or effects.has("stun") or effects.has("silence") or not target: return
	summon_clock += delta
	if summon_clock >= summon_interval and alive_minions() < max_minions:
		_start_cast()

func alive_minions() -> int:
	var count: int = 0
	for minion in minions:
		if is_instance_valid(minion) and minion.get("state") == 'alive': count += 1
	return count

func _start_cast() -> void:
	casting = true
	$exclamation.visible = true
	get_tree().create_timer(cast_time).timeout.connect(_finish_cast)

func _finish_cast() -> void:
	if not is_inside_tree(): return
	casting = false
	$exclamation.visible = false
	if state != 'alive' or effects.has("stun") or effects.has("silence"): return
	summon_clock = 0
	_summon()

func _summon() -> void:
	var to_spawn: int = mini(summon_count, max_minions - alive_minions())
	for i in to_spawn:
		var scene: PackedScene = _choose_minion()
		if not scene: return
		var minion: Node2D = scene.instantiate()
		minion.global_position = _find_summon_point()
		minion.possessable = false
		if is_in_group("ally"):
			minion.remove_from_group("enemy")
			minion.add_to_group("ally")
			minion.get_node("sprite").modulate = ally_tint
		get_parent().add_child(minion)
		minions.append(minion)
		minion.tree_exited.connect(minions.erase.bind(minion))

func _choose_minion() -> PackedScene:
	var options: Array[Dictionary] = []
	var total_weight: float = 0
	for type in minion_types:
		var scene: PackedScene = type["scene"]
		if type.has("max") and alive_minions_of(scene) >= type["max"]: continue
		options.append(type)
		total_weight += type.get("weight", 1)
	if options.is_empty() or total_weight <= 0: return null
	var roll: float = randf() * total_weight
	for type in options:
		roll -= type.get("weight", 1)
		if roll < 0: return type["scene"]
	return options.back()["scene"]

func alive_minions_of(scene: PackedScene) -> int:
	var count: int = 0
	for minion in minions:
		if is_instance_valid(minion) and minion.get("state") == 'alive' and minion.scene_file_path == scene.resource_path: count += 1
	return count

func _find_summon_point() -> Vector2:
	var space: PhysicsDirectSpaceState2D = get_world_2d().direct_space_state
	var start_angle: float = randf() * TAU
	for i in 8:
		var point: Vector2 = global_position + Vector2.from_angle(start_angle + i * TAU / 8) * summon_distance
		var query := PhysicsPointQueryParameters2D.new()
		query.position = point
		query.collision_mask = 128
		if space.intersect_point(query, 1).is_empty(): return point
	return global_position


func _on_ability() -> bool:
	if not super(): return false
	if state == 'possessed': _summon()
	return true

func _on_take_damage(d: float) -> void:
	var was_alive: bool = state == 'alive'
	super(d)
	if was_alive and state == 'dead': _dismiss_minions()

## minions also vanish when a possessed summoner dies
func _exit_tree() -> void:
	_dismiss_minions()

##The minions vanish when the summoner dies (unless the player has possessed one).
func _dismiss_minions() -> void:
	for minion in minions:
		if is_instance_valid(minion) and minion.get("state") != 'possessed':
			minion.queue_free()
	minions.clear()
