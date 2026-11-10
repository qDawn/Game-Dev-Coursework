extends Area2D

var attacking_group: String
var damage: float = 0.5

func _on_expiry_timer_timeout() -> void:
	queue_free()


func _on_damage_timer_timeout() -> void:
	for body in get_overlapping_bodies():
		if body.is_in_group("player"): continue
		if body.is_in_group(attacking_group): 
			body.emit_signal("take_damage",damage)
			body.emit_signal("take_effect","slow",1)
		elif not body.is_in_group("ally"): 
			body.emit_signal("heal",damage)
