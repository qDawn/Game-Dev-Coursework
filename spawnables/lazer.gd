extends Node2D

signal setup
var lazer_width: float = 10
var damage: float = 1
var target_group: String = "ally"

func _ready() -> void:
	connect("setup",_on_setup)


func _on_expiration_timer_timeout() -> void:
	for body in $collision_box.get_overlapping_bodies():
		if body.is_in_group(target_group):
			body.emit_signal("take_damage", damage)
	queue_free()

func _on_prime_timer_timeout() -> void:
	$Line2D.width = lazer_width
	$expiration_timer.start()
	
func _on_setup(prime_time: float, start_point: Vector2, end_point: Vector2, width: float) -> void:
	$prime_timer.start(prime_time)
	$Line2D.add_point(start_point)
	$Line2D.add_point(end_point)
	$collision_box/CollisionShape2D.shape.a = start_point
	$collision_box/CollisionShape2D.shape.b = end_point
	width = width
