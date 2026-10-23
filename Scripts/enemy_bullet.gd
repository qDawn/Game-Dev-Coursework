extends Area2D

const speed = 150
signal bulletDied

var velocity : Vector2
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	position.x += speed * delta * velocity.x
	position.y += speed * delta * velocity.y

	for area in get_overlapping_areas():
		if area.is_in_group("player_bullet"):
			bulletDied.emit()
			queue_free()
		
		if area.is_in_group("player"):
			bulletDied.emit()
			queue_free()
