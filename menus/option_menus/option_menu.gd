extends CanvasLayer

const CONTROLS_MENU = preload("uid://ddgm7b33h2whq")

var buttons
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if buttons:
		pass
	if $VBoxContainer/Controls.button_pressed:
		show_controls()
	
	if $VBoxContainer/Visuals.button_pressed:
		show_visuals()
		
	if $VBoxContainer/Return.button_pressed:
		Options.save_options()
		get_parent().get_node("PauseMenu").show()
		queue_free()
			

func show_controls():
	var controls = CONTROLS_MENU.instantiate()
	get_parent().add_child(controls)
	visible = false
	
	
func show_visuals():
	pass
	
	
