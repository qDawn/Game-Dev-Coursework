
extends "res://enemies/superclasses/summoner_enemy.gd"

const IMP_ENEMY = preload("res://enemies/melee/imp_enemy.tscn")
 
func _ready() -> void:
	super()
	minion_types = [{"scene": IMP_ENEMY, "weight": 1}]
	max_health = 25
	current_health = 25
	speed = 240
	min_range = 450
	attack_range = 0
	$weapon.hide()
	summon_count = 1
	summon_interval = 10.0
	max_minions = 2
