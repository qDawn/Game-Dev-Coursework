extends Area2D

var smite_damage : int = 15
var attack_group : String


func _process(delta: float) -> void:
	$Sprite2D.self_modulate = Color(1,1,1,($timer.wait_time-$timer.time_left)/$timer.wait_time)

func _on_timer_timeout() -> void:
	for body in get_overlapping_bodies():
		if body.is_in_group(attack_group):
			body.emit_signal('take_damage', smite_damage)
	queue_free()
