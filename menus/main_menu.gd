extends Control



func _ready() -> void:
	Highscores.load_high_scores()
	var highscore_str: String = "Top highscores\n"
	for highscore in Highscores.high_scores:
		highscore_str += "%s\n" % highscore
	$highscores_label.text = highscore_str

func _on_play_button_pressed() -> void:
	PlayerInfo.start_new_run()
	Options.load_options()
	get_tree().change_scene_to_file("res://game.tscn")

func _on_quit_button_pressed() -> void:
	get_tree().quit()

func _on_compendium_button_pressed() -> void:
	get_tree().change_scene_to_file("res://menus/compendium_stage.tscn")
