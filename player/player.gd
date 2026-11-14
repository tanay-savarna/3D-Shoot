extends CharacterBody3D

@onready var camera = %Camera3D 
@onready var damage_area = %DamageArea

var health = 100.0
const DAMAGE_RATE = 20.0

@onready var health_bar = %HealthBar

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
		
	if event.is_action_pressed("activate_rapid_fire"):
		activate_rapid_fire()

	if event.is_action_pressed("activate_jetpack"):
		activate_jetpack()
		
	if event.is_action_pressed("activate_speed_boost"):
		activate_speed_boost()



var normal_speed = 5.5
var sprint_speed = 7.0
var rapid_fire = false
var jetpack_active = false
var jetpack_force = 10.0
var rapid_fire_charges = 0
var jetpack_charges = 0
var speed_boost_charges = 0
var speed_boost_active = false

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
	
	
	
	if jetpack_active:
		if Input.is_action_pressed("jump"):
			velocity.y = jetpack_force
		else:
			velocity.y -= 5.0 * delta
	else:
		velocity.y -= 20.0 * delta
		
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = 10.0
	
	elif Input.is_action_just_released("jump") and velocity.y > 0.0:
		velocity.y = 0.0
	
	move_and_slide()
	
	
	var mob_collisions = 0

	for body in damage_area.get_overlapping_bodies():
		if body.is_in_group("mob"):
			mob_collisions += 3

	health -= DAMAGE_RATE * mob_collisions * delta
	health = maxf(health, 0)

	health_bar.value = health

	if health <= 0:
		get_tree().reload_current_scene.call_deferred()
	
	
	if Input.is_action_pressed("shoot") and %Timer.is_stopped():
		shoot_bullet()
		
		if rapid_fire:
			%Timer.wait_time = 0.1
		else:
			%Timer.wait_time = 0.2


func activate_rapid_fire():
	if rapid_fire_charges <= 0 or rapid_fire:
		return

	rapid_fire_charges -= 1
	rapid_fire = true

	await get_tree().create_timer(10.0).timeout

	rapid_fire = false

func activate_jetpack():
	if jetpack_charges <= 0 or jetpack_active:
		return

	jetpack_charges -= 1
	jetpack_active = true

	await get_tree().create_timer(8.0).timeout

	jetpack_active = false
	
func activate_speed_boost():
	if speed_boost_charges <= 0 or speed_boost_active:
		return

	speed_boost_charges -= 1
	speed_boost_active = true

	normal_speed = 10.0
	sprint_speed = 13.0

	await get_tree().create_timer(8.0).timeout

	normal_speed = 5.5
	sprint_speed = 7.0
	speed_boost_active = false

func update_ability_buttons():
	%RapidFireButton.text = "🔥 RAPID FIRE (10 kills) (R) - " + str(rapid_fire_charges)
	%JetpackButton.text = "🚀 JETPACK (20 kills) (F) - " + str(jetpack_charges)
	%SpeedBoostButton.text = "⚡ SPEED BOOST (30 kills) (E) - " + str(speed_boost_charges)

func shoot_bullet():
	@warning_ignore("unused_local_constant")
	const BULLET_3D = preload("res://player/bullet_3d.tscn")
	@warning_ignore("unused_variable")
	var new_bullet = BULLET_3D.instantiate()
	%Marker3D.add_child(new_bullet)
	
	new_bullet.global_transform = %Marker3D.global_transform
	
	
	
	%Timer.start()
	%AudioStreamPlayer.play()
	$AnimationPlayer.play("gun")
