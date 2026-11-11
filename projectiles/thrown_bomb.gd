extends Area2D

## Pixels per second along the ground. Height is faked by scaling the sprite.
var speed: float = 320
var direction: Vector2 = Vector2.RIGHT
## Seconds from release until the bomb reaches its landing point.
var flight_time: float = 0.7
var damage: float = 5
var blast_radius: float = 70
## 0 explodes on impact. Above 0, the bomb lands and waits, then explodes.
var fuse_time: float = 0.0
var attacking_group: String = "ally"

func _ready() -> void:
	#set blast radius
	$blast_radius/CollisionShape2D.shape.radius = blast_radius
	
	var points = _circle_points(blast_radius)
	$blast_warning.polygon = points
	$blast_warning.color = Color(1.0, 0.45, 0.1, 0.28)
	
	#create visual effect of being airbourne
	var tween: Tween = create_tween()
	tween.tween_property($sprite,"scale",$sprite.scale*2,flight_time/2)
	tween.tween_property($sprite,"scale",$sprite.scale,flight_time/2)
	tween.tween_callback(_begin_fuse)

func _physics_process(delta: float) -> void:
	global_position += speed * delta * direction

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group(attacking_group): 
		$fuse_timer.stop()
		_on_fuse_timer_timeout()

func _begin_fuse() -> void:
	# Grow the danger circle out to the blast radius while the fuse burns.
	var tween_fuse := create_tween()
	tween_fuse.tween_property($blast_warning, "scale", Vector2.ONE, fuse_time)
	
	#stop moving
	speed = 0
	if fuse_time > 0: $fuse_timer.start(fuse_time)
	else: _on_fuse_timer_timeout()

func _circle_points(radius: float) -> PackedVector2Array:
	var points := PackedVector2Array()
	for i in 32:
		points.append(Vector2.from_angle(TAU * float(i) / 32.0) * radius)
	return points

func _on_fuse_timer_timeout() -> void:
	for body in $blast_radius.get_overlapping_bodies():
		if body.is_in_group(attacking_group): body.emit_signal("take_damage", damage)
	_spawn_blast()

func _spawn_blast() -> void:
	#hide bomb
	$sprite.visible = false
	
	#create flash
	var flash := Polygon2D.new()
	flash.polygon = _circle_points(blast_radius)
	flash.color = Color(1.0, 0.28, 0.05, 0.8) if fuse_time > 0.0 else Color(1.0, 0.5, 0.1, 0.7)
	add_child(flash)
	
	
	#make flash fade
	var tween_fade := flash.create_tween()
	tween_fade.tween_property(flash, "modulate:a", 0.0, 0.25)
	tween_fade.tween_callback(queue_free)
