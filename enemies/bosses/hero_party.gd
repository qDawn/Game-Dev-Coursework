extends "res://enemies/superclasses/enemy.gd"


func _ready() -> void:
	super()
	max_health = 500
	current_health = 500
	speed = 0
	min_range = 0
	attack_range = 0
	attack_cooldown = 2
	damage = 0
	possessable = false
	
func _process(_delta: float) -> void:
	pass
	
func _physics_process(_delta: float) -> void:
	pass

func _on_take_damage(d: float) -> void:
	self.current_health -= d
