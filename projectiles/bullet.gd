extends Area2D

var speed: float = 150
var direction : Vector2
var damage: int = 1
var effects: Dictionary[String,int] = {}
var splitting: bool = false
var attacking_group: String = "ally"
var already_hit_entity: bool = false
signal add_effect

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	global_position += speed * delta * direction
	
func _on_expiry_timer_timeout() -> void:
	queue_free()

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group(attacking_group) and not already_hit_entity:
		already_hit_entity = true
		for effect in effects: 
			body.emit_signal("take_effect", effect, effects[effect])
		body.emit_signal('take_damage',damage)
		queue_free()
	elif not body.is_in_group('ally') and not body.is_in_group('enemy'):
		queue_free()

func _on_add_effect(effect_name: String, duration: float) -> void:
	effects[effect_name] = duration
