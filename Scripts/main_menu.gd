extends Control

const GAME_SCENE := "res://Scenes/game.tscn"

@onready var play_button: Button = %PlayButton
@onready var quit_button: Button = %QuitButton


func _ready() -> void:
	play_button.pressed.connect(_on_play_pressed)
	quit_button.pressed.connect(get_tree().quit)
	play_button.grab_focus()


func _on_play_pressed() -> void:
	PlayerInfo.start_new_run()
	get_tree().change_scene_to_file(GAME_SCENE)

#mibombababa
