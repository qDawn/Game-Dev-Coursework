extends CharacterBody2D

signal take_damage
signal cancel_possession

const PLAYER_BULLET = preload("uid://bys54qkalrh2b")

var speed: float = 400

var invincible: bool = false
var attack_cooldown: bool = false
var possession_cooldown: bool = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if not PlayerInfo.possession_target: #if there is currently no possession target
		move_and_collide(PlayerInfo.get_player_direction()*speed*delta)
	else: 
		global_position = PlayerInfo.possession_target.global_position
	
	#attacking logic
	if Input.is_action_pressed('shoot'):
		var direction: Vector2 = global_position.direction_to(get_global_mouse_position())
		if PlayerInfo.possession_target:
			PlayerInfo.possession_target.emit_signal('attack', direction)
		elif not attack_cooldown:
			var bullet: Area2D = PLAYER_BULLET.instantiate()
			bullet.global_position = global_position
			bullet.direction = direction
			bullet.speed = 500
			
			get_tree().root.add_child(bullet)
			
			attack_cooldown = true
			$attack_cooldown.start()
		
	#possession logic
	if Input.is_action_just_pressed('possess') and not PlayerInfo.possession_target:
		var available_hosts: Array[Node2D] = $possession_range.get_overlapping_bodies()
		if available_hosts:
			var selected_host: Node2D = available_hosts[0]
			for host in available_hosts:
				if get_global_mouse_position().distance_to(host.global_position) < get_global_mouse_position().distance_to(selected_host.global_position):
					selected_host = host
			#make player invisible and disable hitbox
			$sprite.visible = false
			$hitbox.disabled = true
			#set the possession target
			PlayerInfo.possession_target = selected_host
			#send a signal to the target to let it know that it is possessed.
			selected_host.emit_signal('possession')
			
	#cancel possession logic
	if Input.is_action_just_pressed('cancel_possession') and PlayerInfo.possession_target:
		PlayerInfo.possession_target.emit_signal("take_damage", PlayerInfo.possession_target.max_health)

func _on_take_damage(damage: int) -> void:
	if not invincible:
		#player only ever takes 1 damage from sources, become invincible.
		PlayerInfo.take_damage(1)
		invincible = true
		#sprite becomes transparent
		$sprite.self_modulate = Color(1,1,1,0.5)
		_flash_red()
		
		#send a signal to the HUD
		$ui.emit_signal("health_changed")
		
func _flash_red() -> void:
	$sprite.modulate = Color(1.0, 0.25, 0.25)
	create_tween().tween_property($sprite, "modulate", Color.WHITE, 0.2)

func _on_invincible_timer_timeout() -> void:
	invincible = false
	$sprite.self_modulate = Color(1,1,1,1)

func _on_attack_cooldown_timeout() -> void:
	attack_cooldown = false

func _on_cancel_possession() -> void:
	#reset visibility and hitbox
	$sprite.visible = true
	$hitbox.disabled = false
	#reset the possession target
	PlayerInfo.possession_target = null
