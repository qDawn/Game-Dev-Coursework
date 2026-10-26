extends VBoxContainer

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#We want it to constantly show the player's stats.
	$player_health.text = 'HP: %s/%s' % [PlayerInfo.current_health, PlayerInfo.max_health]
	$score.text = '%s' % PlayerInfo.score
