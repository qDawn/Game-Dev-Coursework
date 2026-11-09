extends Node2D

signal gameover

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	connect("gameover",_on_gameover)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func _on_gameover() -> void:
	for enemy in get_tree().get_nodes_in_group("enemy"):
		enemy.queue_free()
	get_tree().change_scene_to_file("res://menus/death_menu.tscn")
