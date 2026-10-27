extends CanvasLayer

signal health_changed
signal score_changed

@onready var player_health_bar: TextureProgressBar = %player_health_bar
@onready var possession_health_bar: TextureProgressBar = $possession_health_bar
@onready var score_label: Label = %score_label

func _ready() -> void:
	emit_signal("health_changed")
	emit_signal("score_changed")

func _process(delta: float) -> void:
	if PlayerInfo.possession_target:
		possession_health_bar.visible = true
		possession_health_bar.value = possession_health_bar.max_value * (PlayerInfo.possession_target.current_health/PlayerInfo.possession_target.max_health)
	else:
		possession_health_bar.visible = false

func _on_health_changed() -> void:
	player_health_bar.value = player_health_bar.max_value * (PlayerInfo.current_health / PlayerInfo.max_health)

func _on_score_changed() -> void:
	score_label.text = "Score  %d" % PlayerInfo.score
