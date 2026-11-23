extends "res://enemies/superclasses/melee_enemy.gd"
class_name clone_enemy

signal leader_died

const CLONE_ENEMY = preload("uid://cvwu0iar6767i")
const max_clone_count : int = 2
# Number of times it can clone
var clone_count : int = max_clone_count
# The leader is the original enemy spawend by wave_spawner. If leader dies all the cloned enemies dies
var leader : clone_enemy

func _ready() -> void:
	super()
	max_health = 20
	current_health = 20
	speed = 200
	min_range = 50
	attack_range = 100
	ability_cooldown = 1
	
func _process(delta: float) -> void:
	super(delta)
	if not state == "possessed" and not state == "dead":
		_on_ability()
		
func _on_attack(direction: Vector2) -> bool:
	super(direction)
	return true
	
func _on_take_damage(d: float) -> void:
	super(d)
	if state == 'dead':
		if leader == self:
			leader_died.emit()
		else:
			# Clones cannot be possessed
			$possession_window.stop()
			$possession_window.emit_signal("timeout")


func _on_ability_cooldown_timeout() -> void:
	create_cloned_enemy()

func create_cloned_enemy() -> void:
	if clone_count <= 0: return
	
	clone_count-=1
	var enemy : clone_enemy  = CLONE_ENEMY.instantiate()
	enemy.global_position = global_position + Vector2(5, 5)
	enemy.clone_count = clone_count
	enemy.leader = leader
	enemy.ability_cooldown = ability_cooldown + 5
	enemy.possessable = false
	enemy.current_health = max_health / 2
	
	if leader == null:
		leader = self
	enemy.leader = leader
	leader.leader_died.connect(enemy._on_leader_died)
	
	if is_in_group("ally"):
		enemy.remove_from_group("enemy")
		enemy.add_to_group("ally")

	get_tree().current_scene.add_child(enemy)
		
func _on_leader_died() -> void:
	queue_free()
	
func _on_possession() -> void:
	super()
	clone_count = max_clone_count
	
