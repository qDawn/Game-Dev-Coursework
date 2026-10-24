extends CharacterBody2D

signal take_damage
signal possess

const PLAYER_BULLET = preload("uid://bys54qkalrh2b")

var speed: float = 300
var invincible: bool = false
var attack_cooldown: bool = false

var currently_possessing: bool = false
var possession_cooldown: bool = false
var possession_target: RigidBody2D = null

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if currently_possessing: 
		possession_target.global_position = global_position
	
	#player movement
	#horizontal movement
	if Input.is_action_pressed("move_right"): velocity.x = speed*delta
	elif Input.is_action_pressed("move_left"): velocity.x = -speed*delta
	else: velocity.x = 0
	#vertical movement
	if Input.is_action_pressed("move_up"): velocity.y = -speed*delta
	elif Input.is_action_pressed("move_down"): velocity.y = speed*delta
	else: velocity.y = 0
	move_and_collide(velocity)
	
	#attacking logic
	if Input.is_action_pressed('shoot'):
		var direction: Vector2 = global_position.direction_to(get_global_mouse_position())
		if currently_possessing:
			possession_target.emit_signal('attack', direction)
		elif not attack_cooldown:
			var bullet: Area2D = PLAYER_BULLET.instantiate()
			bullet.global_position = global_position
			bullet.direction = direction
			bullet.speed = 500
			get_tree().root.add_child(bullet)
			
			attack_cooldown = true
			$attack_cooldown.start()
		
	#possession logic
	if Input.is_action_just_pressed('possess') and not currently_possessing:
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
			possession_target = selected_host
			currently_possessing = true
			selected_host.emit_signal('possession')

func _on_take_damage(damage: int) -> void:
	if not invincible:
		#take damage, become invincible, sprite becomes transparent.
		PlayerInfo.current_health -= damage
		invincible = true
		$sprite.self_modulate = Color(1,1,1,0.5)
		
func _on_invincible_timer_timeout() -> void:
	invincible = false
	$sprite.self_modulate = Color(1,1,1,1)

func _on_attack_cooldown_timeout() -> void:
	attack_cooldown = false
