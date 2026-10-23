extends Node2D

# Every Active ability should inherit 
# Possible states: active, available, cooldown
var state = "available"
var user : Node2D
var size

func _ready() -> void:
	$CooldownTimer.timeout.connect(set_state_available)
	$ActiveTimer.timeout.connect(set_state_cooldown)

func _process(delta: float) -> void:
	if state == "active":
		ability(delta)

func set_user(owner: Node2D):
	user = owner
	
func ability(delta: float) -> void:
	pass
	
func activate_ability() -> void:
	if state == "available":
		state = "active"
		$ActiveTimer.start()
	
func set_state_available() -> void:
	state = "available"
	$CooldownTimer.stop()
	
func set_state_cooldown() -> void:
	state = "cooldown"
	$ActiveTimer.stop()
	$CooldownTimer.start()
