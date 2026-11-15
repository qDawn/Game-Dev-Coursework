
extends "res://enemies/superclasses/summoner_enemy.gd"

const IMP_ENEMY = preload("res://enemies/melee/imp_enemy.tscn")
 
func _ready() -> void:
	super()
	minion_types = [{"scene": IMP_ENEMY, "weight": 1}]
	max_health = 25
	current_health = 25
	speed = 160
	min_range = 450
	attack_range = 0
	$weapon.hide()
	summon_count = 2
	summon_interval = 6.0
	max_minions = 4
 
