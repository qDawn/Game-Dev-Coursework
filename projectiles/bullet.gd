extends Area2D

var speed: float = 150
var direction : Vector2
var damage: int = 1
var effects: Dictionary[String,int] = {}
signal add_effect

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	global_position += speed * delta * direction
	

func _on_expiry_timer_timeout() -> void:
	queue_free()

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group('player') and is_in_group("enemy_bullet") or body.is_in_group('enemy') and is_in_group("player_bullet"):
		body.emit_signal('take_damage',damage)
		for effect in effects: 
			body.emit_signal("take_effect", effect, effects[effect])
		queue_free()
	elif not body.is_in_group('player') and not body.is_in_group('enemy'):
		queue_free()


func _on_add_effect(effect_name: String, duration: float) -> void:
	effects[effect_name] = duration
