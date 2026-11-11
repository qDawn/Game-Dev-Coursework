extends "res://projectiles/basic_bullet.gd"

var base_damage : int = 5

func _ready() -> void:
	attacking_group = "enemy"
	
func _proce1ss(delta: float) -> void:
	for body in get_overlapping_bodies():
		if body.is_in_group('enemy'):
			var bonus_damage: int = int(body.max_health/10)
			body.emit_signal('take_damage',base_damage+bonus_damage)
			queue_free()
		elif not body.is_in_group("ally"):
			queue_free()

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemy"):
		var bonus_damage: int = int(body.max_health/10)
		damage = base_damage + bonus_damage
	super(body)
		
func _on_expiry_timer_timeout() -> void:
	queue_free()
