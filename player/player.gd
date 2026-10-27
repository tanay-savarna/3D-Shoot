extends CharacterBody3D

@onready var camera = %Camera3D 

var normal_fov = 75.0
var sprint_fov = 90.0 


func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _unhandled_input(event):
	if event is InputEventMouseMotion:
		rotation_degrees.y -= event.relative.x * 0.5 #This is for the sensitivity note to change if u want later on
		%Camera3D.rotation_degrees.x -= event.relative.y * 0.2 #Same applies for this one.
		%Camera3D.rotation_degrees.x = clamp(%Camera3D.rotation_degrees.x,-80.0, 80.0
		)
	elif event.is_action_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)



var normal_speed = 5.5
var sprint_speed = 7.0

func _physics_process(delta: float):
	
	var current_speed = normal_speed
	@warning_ignore("unused_variable")
	var target_fov = normal_fov
	
	if Input.is_action_pressed("sprint"):
		current_speed = sprint_speed
		target_fov = sprint_fov
	
		# 2. Smoothly transition the camera FOV using lerp
	# delta * 5.0 controls how fast the transition happens. Increase 5.0 for snappy, decrease for slow.
	camera.fov = lerp(camera.fov, target_fov, delta * 7.5)
	
	@warning_ignore("unused_variable")
	var input_direction_2D = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	
	@warning_ignore("unused_variable")
	var input_direction_3D = Vector3(input_direction_2D.x, 0.0, input_direction_2D.y)
	
	var direction = transform.basis * input_direction_3D
	
	velocity.x = direction.x * current_speed
	velocity.z = direction.z * current_speed
	
	velocity.y -= 20.0 * delta
	
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = 10.0
	
	elif Input.is_action_just_released("jump") and velocity.y > 0.0:
		velocity.y = 0.0
	
	move_and_slide()
	
	
	if Input.is_action_pressed("shoot") and %Timer.is_stopped():
		shoot_bullet()



func shoot_bullet():
	@warning_ignore("unused_local_constant")
	const BULLET_3D = preload("res://player/bullet_3d.tscn")
	@warning_ignore("unused_variable")
	var new_bullet = BULLET_3D.instantiate()
	%Marker3D.add_child(new_bullet)
	
	new_bullet.global_transform = %Marker3D.global_transform
	
	
	%Timer.start()
