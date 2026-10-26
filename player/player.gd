extends CharacterBody3D



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



@warning_ignore("unused_parameter")
func _physics_process(delta: float):
	@warning_ignore("unused_local_constant")
	const SPEED = 5.5
	
	@warning_ignore("unused_variable")
	var input_direction_2D = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	
	@warning_ignore("unused_variable")
	var input_direction_3D = Vector3(input_direction_2D.x, 0.0, input_direction_2D.y)
	
	var direction = transform.basis * input_direction_3D
	
	velocity.x = direction.x * SPEED
	velocity.z = direction.z * SPEED
	
	velocity.y -= 20.0 * delta
	
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = 10.0
	
	elif Input.is_action_just_released("jump") and velocity.y > 0.0:
		velocity.y = 0.0
	
	move_and_slide()
