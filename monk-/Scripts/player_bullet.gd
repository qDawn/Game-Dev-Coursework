extends Area2D

signal bulletDied
var rotatingPlayer = true
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if rotatingPlayer:
		pass
		
	for area in get_overlapping_areas():
		if area.is_in_group("enemy_bullet"):
			bulletDied.emit()
			queue_free()
		
		if area.is_in_group("enemy"):
			bulletDied.emit()
			queue_free()
