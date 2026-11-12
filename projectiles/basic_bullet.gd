extends Area2D

var speed: float = 150
var direction : Vector2
var damage: float = 1
var effects: Dictionary[String,float] = {}
var splitting: bool = false
var attacking_group: String = "ally"
var piercing: int = 1
var pierce_count: int = 0

signal add_effect

func _ready() -> void:
	connect("add_effect",_on_add_effect)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	global_position += speed * delta * direction
	
func _on_expiry_timer_timeout() -> void:
	queue_free()

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group(attacking_group):
		for effect in effects: 
			body.emit_signal("take_effect", effect, effects[effect])
		body.emit_signal('take_damage',damage)
		pierce_count += 1
		if pierce_count == piercing:
			_on_expiry_timer_timeout()
	elif not body.is_in_group("enemy") and not body.is_in_group("ally"):
		_on_expiry_timer_timeout()

func _on_add_effect(effect_name: String, duration: float) -> void:
	effects[effect_name] = duration
