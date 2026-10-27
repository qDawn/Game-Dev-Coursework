extends CanvasLayer

@onready var health_bar: ProgressBar = %HealthBar
@onready var score_label: Label = %ScoreLabel


func _ready() -> void:
	PlayerInfo.health_changed.connect(update_health)
	PlayerInfo.score_changed.connect(update_score)
	update_health()
	update_score()


func update_health() -> void:
	health_bar.max_value = PlayerInfo.max_health
	health_bar.value = PlayerInfo.current_health


func update_score() -> void:
	score_label.text = "Score  %d" % PlayerInfo.score
