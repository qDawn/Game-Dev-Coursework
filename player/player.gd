extends CharacterBody2D

signal take_damage
signal cancel_possession

const PLAYER_BULLET = preload("uid://bys54qkalrh2b")
const BASE_SPEED: float = 400
var speed: float = BASE_SPEED

var ability_cooldown: bool = false
var possession_cooldown: bool = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if not PlayerInfo.possession_target: #if there is currently no possession target
		velocity = PlayerInfo.get_player_direction()*speed*delta
		move_and_collide(velocity)
	else: 
		global_position = PlayerInfo.possession_target.global_position
		velocity = PlayerInfo.possession_target.velocity
	
	#attacking logic
	if Input.is_action_pressed('shoot'):
		var direction: Vector2 = global_position.direction_to(get_global_mouse_position())
		if PlayerInfo.possession_target:
			PlayerInfo.possession_target.emit_signal('attack', direction)
		elif $attack_cooldown.is_stopped():
			var bullet: Area2D = PLAYER_BULLET.instantiate()
			bullet.global_position = global_position
			bullet.direction = direction
			bullet.speed = 500
			get_tree().root.add_child(bullet)
			$attack_cooldown.start()
	
	#ability logic
	if Input.is_action_just_pressed('ability'):
		if PlayerInfo.possession_target:
			PlayerInfo.possession_target.emit_signal('ability')
		elif $ability_cooldown.is_stopped() and $invincible_timer.is_stopped():
			_on_start_invincibility(3)
			$ability_cooldown.start(10)
			
	if not PlayerInfo.possession_target:
		if not $invincible_timer.is_stopped():
			$ui.emit_signal("ability_changed", $invincible_timer.time_left/$invincible_timer.wait_time)
		elif not $ability_cooldown.is_stopped():
			$ui.emit_signal("ability_changed", 1-$ability_cooldown.time_left/$ability_cooldown.wait_time)
		else:
			$ui.emit_signal("ability_changed", 1)

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
			#if the player was using ability
			_on_invincible_timer_timeout()

	#possession cancel logic
	if Input.is_action_just_pressed('cancel_possession') and PlayerInfo.possession_target:
		PlayerInfo.possession_target.queue_free()
		#reset the possession target
		PlayerInfo.possession_target = null
		#reset visibility and hitbox
		$sprite.visible = true
		$hitbox.disabled = false
		#reset ability cooldown immediately
		$ability_cooldown.stop()


func _on_take_damage(_damage: int) -> void:
	#player only ever takes 1 damage from sources, become invincible.
	PlayerInfo.take_damage(1)
	_on_start_invincibility(2)
	#send a signal to the HUD
	$ui.emit_signal("health_changed")

func _on_invincible_timer_timeout() -> void:
	speed = BASE_SPEED
	$sprite.self_modulate = Color(1,1,1,1)
	set_collision_layer_value(1,true)
	set_collision_mask_value(1,true)
	set_collision_mask_value(5,false)
	$ability_cooldown.start()

func _on_start_invincibility(duration: float) -> void:
	speed *= 1.2
	$sprite.self_modulate = Color(1,1,1,0.5)
	set_collision_layer_value(1,false)
	set_collision_mask_value(1,false)
	set_collision_mask_value(5,true)
	$invincible_timer.start(duration)

func _on_cancel_possession() -> void:
	#brief invincibility
	_on_start_invincibility(0.5)
	$ability_cooldown.start()
	#reset visibility and hitbox
	$sprite.visible = true
	$hitbox.disabled = false
	#reset the possession target
	PlayerInfo.possession_target = null
