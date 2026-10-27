extends Node2D

# Every Active ability should inherit 
# Possible states: active, available, cooldown
var state = "available"
var user : Node2D

func activate_ability() -> void:
	if state == "available":
		state = "active"
		$ActiveTimer.start()

func _on_cooldown_timer_timeout() -> void:
	state = "available"
func _on_active_timer_timeout() -> void:
	state = "cooldown"
