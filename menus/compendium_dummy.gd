extends CharacterBody2D

signal take_damage
signal take_effect

var speed: float = 0.0

func _ready() -> void:
	take_damage.connect(_on_take_damage)
	take_effect.connect(_on_take_effect)

func _on_take_damage(_amount: float) -> void:
	pass

func _on_take_effect(_effect: String, _duration: float) -> void:
	pass

func apply_knockback(_push: Vector2) -> void:
	pass
