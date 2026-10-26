extends Area2D

var speed: float = 150
var direction : Vector2
var damage: int = 1

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	global_position += speed * delta * direction
	for body in get_overlapping_bodies():
		if body.is_in_group('player') and is_in_group("enemy_bullet") or body.is_in_group('enemy') and is_in_group("player_bullet"):
			body.emit_signal('take_damage',damage)
			queue_free()

func _on_expiry_timer_timeout() -> void:
	queue_free()
