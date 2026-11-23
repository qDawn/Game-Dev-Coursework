extends CanvasLayer

const SECTION : String = "controls"
var cur_button : Button
var binds : Dictionary = {}


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for button in $Control.get_children():
		button.pressed.connect(_on_control_button_pressed.bind(button))
		#shows which key is binded to that action
		var bind = get_bind(button)
		button.get_node("bind").text = bind
		is_duplicate(bind)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if $Return.button_pressed:
		get_parent().get_node("OptionMenu").show()
		queue_free()

func is_duplicate(bind : String) -> bool:
	if binds.has(bind):
		cur_button.get_node("bind").text = "Selected bind is already used"
		return true
	else:
		binds[bind] = true
		return false

func _on_control_button_pressed(button : Button):
	button.get_node("bind").text = "Waiting for Input"
	cur_button = button

func _input(event: InputEvent) -> void:
	if cur_button == null: return
	
	# Only keyboard and mouse button presses are valid
	if event is InputEventKey or event is InputEventMouseButton:
		
		change_bind(event)
			
func change_bind(event : InputEvent)-> void:
	var old_bind : String = get_bind(cur_button)
	# Only updated if the binds are different
	if old_bind == event.as_text(): 
		cur_button.get_node("bind").text = old_bind
		cur_button = null
		return
	
	# If it is a duplicate then keep prompting the user to select an input
	if !is_duplicate(event.as_text()):
		binds.erase(old_bind)
		InputMap.action_erase_events(cur_button.name)
		InputMap.action_add_event(cur_button.name, event)
		cur_button.get_node("bind").text = get_bind(cur_button)
		save_bind(event)
		cur_button = null
		
func save_bind(event : InputEvent) -> void:
	if event is InputEventKey:
		Options.set_controls_option(SECTION, cur_button.name, {"type": "keyboard", "val" : event.physical_keycode})	
	elif event is InputEventMouseButton:
		Options.set_controls_option(SECTION, cur_button.name, {"type": "mouse", "val" : event.button_index})	
	
func get_bind(button : Button) -> String:
	return InputMap.action_get_events(button.name)[0].as_text().trim_suffix(" - Physical")
	
		
