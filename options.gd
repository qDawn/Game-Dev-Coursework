extends Node


const CONFIG_PATH: String = "user://config.ini"
static var config : ConfigFile = ConfigFile.new()


static func save_options() -> void:
	config.save(CONFIG_PATH)


static func set_option(section : String, key : String, value: String) -> void:
	config.set_value(section, key, value)
	

static func set_controls_option(section : String, key : String, value: Dictionary) -> void:
	config.set_value(section, key, value)	

static func load_options() -> void:
	var err = config.load(CONFIG_PATH)
	if err != OK:	return
	
	load_controls()
	


static func load_controls() -> void:
	for action in config.get_section_keys("controls"):
		
		var event : InputEvent
		var val : Dictionary = config.get_value("controls", action)
		if val.get("type") == "keyboard":
			event = InputEventKey.new()
			event.physical_keycode = val.get("val")
		elif val.get("type") == "mouse":
			event = InputEventMouseButton.new()
			event.button_index = val.get("val")
			
		InputMap.action_erase_events(action)
		InputMap.action_add_event(action, event)
