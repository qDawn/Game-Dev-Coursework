extends "res://enemy.gd"

const abilityScene = preload("res://spread_shoot_active_ability.tscn")
#const abilityScene = preload("res://field_active_ability.tscn")

@export var ability : Node2D

func _ready() -> void:
	super()
	health = 150
	ability = abilityScene.instantiate()
	ability.set_user(self)
	add_child(ability)
	

func shoot_bullets():
	if ability.state != "active":
		super()
	
	
func _process(delta: float) -> void:
	super(delta)
	ability.activate_ability()
