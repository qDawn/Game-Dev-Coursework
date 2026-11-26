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
	if self.current_health < 0:
		$party_healer.current_health = 0
		$wizard_boss.current_health = 0
		queue_free()

func _on_heal(h: float) -> void:
	self.current_health = min(current_health+h/2,max_health)
