extends Label


func _ready() -> void:
	var tween = create_tween()
	tween.tween_property($'.',"global_position",Vector2(global_position.x,global_position.y-20),0.1)
	tween.tween_property($'.',"global_position",Vector2(global_position.x,global_position.y),0.1)

func _on_expiry_timer_timeout() -> void:
	queue_free()
