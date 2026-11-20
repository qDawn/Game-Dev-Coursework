extends "res://projectiles/basic_bullet.gd"

func _ready() -> void:
	attacking_group = "enemy"
	damage = 5
	
func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemy") and not body.is_in_group("boss"):
		damage += int(body.max_health/10)
	super(body)
