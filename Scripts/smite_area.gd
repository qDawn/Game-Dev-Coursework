extends Area2D


func _on_expiry_timer_timeout() -> void:
	queue_free()
