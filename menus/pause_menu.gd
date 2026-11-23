extends CanvasLayer

const MAIN_MENU := "uid://ctph0yn4fj6pl"
const OPTION_MENU := preload("uid://dbtsqrdnhsgin")

var paused : bool = false
var player : Player

func _ready() -> void:
	$MenuButtons.visible = false
	$ColorRect.visible = false


func _process(_delta: float) -> void:
	if player == null:
		player = get_parent().get_node("Player")
		
	
	if Input.is_action_just_pressed("pause") and !paused:
		get_tree().paused = true
		$MenuButtons.visible = true
		$ColorRect.visible = true
		paused = true

	elif Input.is_action_just_pressed("pause") and paused:
		resume()
		
	if $MenuButtons/PanelContainer/Control/MainMenu.button_pressed:
		get_tree().paused = false
		PlayerInfo.start_new_run()
		get_tree().change_scene_to_file(MAIN_MENU)
		
	elif $MenuButtons/PanelContainer/Control/Resume.button_pressed:
		resume()
		
	elif $MenuButtons/PanelContainer/Control/Option.button_pressed:
		var menu = OPTION_MENU.instantiate()
		get_parent().add_child(menu)
		visible = false
		
		
func resume() -> void:
	get_tree().paused = false
	$MenuButtons.visible = false
	$ColorRect.visible = false
	paused = false
