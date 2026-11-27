extends Control


func _ready() -> void:
	Highscores.load_high_scores()
	var highscore_str: String = "Top highscores\n"
	for highscore in Highscores.high_scores:
		highscore_str += "%s\n" % highscore
	$highscores_label.text = highscore_str
	%difficulty_button.select(difficulty_to_index(PlayerInfo.difficulty))

func _on_play_button_pressed() -> void:
	PlayerInfo.start_new_run()
	Options.load_options()
	get_tree().change_scene_to_file("res://game.tscn")

func _on_quit_button_pressed() -> void:
	get_tree().quit()

func _on_compendium_button_pressed() -> void:
	get_tree().change_scene_to_file("res://menus/compendium_stage.tscn")

func _on_difficulty_button_item_selected(index: int) -> void:
	match index:
		0:
			PlayerInfo.difficulty = 0.75 # easy
		1:
			PlayerInfo.difficulty = 1.0 # normal
		2:
			PlayerInfo.difficulty = 1.25 # hard

func difficulty_to_index(difficulty : float) -> int:
	match difficulty:
		0.75:
			return 0
		1.0:
			return 1
		1.25:
			return 2
	return -1
