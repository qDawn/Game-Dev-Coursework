extends Node

var high_scores: Array[int] = []
const SAVE_FILE_PATH: String = "user://high_scores.save"

##Function for adding a new high score to the array of highscores
func add_high_score(new_score: int) -> void:
	if new_score == 0: return
	var current_index: int = 0
	while current_index < high_scores.size() and high_scores[current_index] > new_score: current_index += 1
	if current_index == high_scores.size() and high_scores.size() < 5: high_scores.append(new_score)
	else:
		high_scores.insert(current_index,new_score)
		while high_scores.size() > 5: high_scores.pop_back()
	save_high_scores()

##Function for loading highscores
func load_high_scores() -> void:
	if not FileAccess.file_exists(SAVE_FILE_PATH): return
	var f = FileAccess.open(SAVE_FILE_PATH, FileAccess.READ)
	high_scores = f.get_var()
	f.close()

##Function for saving highscores
func save_high_scores() -> void:
	var f = FileAccess.open(SAVE_FILE_PATH, FileAccess.WRITE)
	f.store_var(high_scores)
	f.close()
