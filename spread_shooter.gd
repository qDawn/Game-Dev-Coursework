extends "res://Scripts/enemy.gd"

const abilityScene = preload("res://Scenes/spread_shoot_active_ability.tscn")
#const abilityScene = preload("res://field_active_ability.tscn")
var ability : Node2D
func _ready() -> void:
	super()
	health = 150
	ability = $SpreadShootActiveAbility
	ability.set_user(self)
	

func shoot_bullets():
	if ability.state != "active":
		super()
	
	
func _process(delta: float) -> void:
	super(delta)
	ability.activate_ability()
