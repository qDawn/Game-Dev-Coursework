extends Area2D

var speed: float = 150
var direction : Vector2

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	global_position += speed * delta * direction
	for body in get_overlapping_bodies():
		if body.is_in_group('enemy'):
			var base_damage: int = 1000
			var bonus_damage: int = int(body.max_health/10)
			body.emit_signal('take_damage',base_damage+bonus_damage)
			queue_free()

func _on_expiry_timer_timeout() -> void:
	queue_free()
