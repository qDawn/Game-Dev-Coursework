extends Area2D

var attacking_group : String


func _on_timer_timeout() -> void:
	queue_free()

func _on_area_entered(area : Area2D):
	if !area.is_in_group("reflected") and area.is_in_group("projectile"):
		area.direction = -area.direction
		area.attacking_group = attacking_group
		area.add_to_group("reflected")
