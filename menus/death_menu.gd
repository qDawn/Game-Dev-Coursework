extends CanvasLayer

const MAIN_MENU := "uid://ctph0yn4fj6pl"
const GAME := "uid://dlbjkwvlm4ula"

var score_label: Label
var restart_button: Button


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS  # keeps the buttons working while paused
	hide()

	# centre everything on screen
	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(center)

	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 14)
	center.add_child(column)

	var title := Label.new()
	title.text = "YOU DIED"
	title.add_theme_font_size_override("font_size", 56)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	column.add_child(title)

	score_label = Label.new()
	score_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	column.add_child(score_label)

	restart_button = _make_button("Try again", column, _on_restart_pressed)
	_make_button("Main menu", column, _on_menu_pressed)
	_make_button("Quit", column, get_tree().quit)

	PlayerInfo.player_died.connect(_on_player_died)


func _make_button(text: String, parent: Node, callback: Callable) -> Button:
	var button := Button.new()
	button.text = text
	button.custom_minimum_size = Vector2(260, 0)
	button.pressed.connect(callback)
	parent.add_child(button)
	return button


func _on_player_died() -> void:
	await get_tree().create_timer(0.6).timeout
	score_label.text = "Score  %d" % PlayerInfo.score
	show()
	get_tree().paused = true
	restart_button.grab_focus()


func _on_restart_pressed() -> void:
	get_tree().paused = false
	PlayerInfo.start_new_run()
	#get_tree().change_scene_to_file(GAME)
	get_tree().reload_current_scene()


func _on_menu_pressed() -> void:
	get_tree().paused = false
	PlayerInfo.start_new_run()
	get_tree().change_scene_to_file(MAIN_MENU)
