extends RigidBody3D
signal killed                     #  For the instant score
signal despawned #  For the delayed smoke poof

var health = 3
var speed = randf_range(2.5, 5.5)
var is_dead = false 

@onready var bat_model = %bat_model
@onready var timer = %Timer
@onready var player = get_node("/root/Game/Player")
@onready var hurt = %Hurt
@onready var ko = %KO

@warning_ignore("unused_parameter")
func _physics_process(delta):
	if is_dead: return
	var direction = global_position.direction_to(player.global_position)
	direction.y = 0.0
	linear_velocity = direction * speed
	bat_model.rotation.y = Vector3.FORWARD.signed_angle_to(direction, Vector3.UP) + PI

func take_damage():
	if is_dead:
		return
	
	bat_model.hurt()
	health -= 1
	hurt.play()
	
	if health <= 0:
		is_dead = true 
		set_physics_process(false)
		gravity_scale = 1.0
		
		var direction = global_position.direction_to(player.global_position) * -1.0
		var random_upward_force = Vector3.UP * randf_range(1.0, 5)
		apply_central_impulse(direction * 15.0 + random_upward_force)
		
		# Tell the game to update the score IMMEDIATELY
		killed.emit() 
		
		timer.start()
		ko.play()

func _on_timer_timeout() -> void:
	# Tell the game where the mob is right before it vanishes
	despawned.emit(global_position) 
	queue_free() 
