extends "res://projectiles/basic_bullet.gd"

var base_damage : int = 5

func _ready() -> void:
	attacking_group = "enemy"
	
func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemy"):
		var bonus_damage: int = int(body.max_health/10)
		damage = base_damage + bonus_damage
	super(body)
