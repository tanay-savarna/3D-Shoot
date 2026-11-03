extends RigidBody3D

signal died

var health = 3
var speed = randf_range(2.5, 5.5)

@onready var bat_model = %bat_model
@onready var timer = %Timer
@onready var player = get_node("/root/Game/Player")
@onready var hurt = %Hurt
@onready var ko = %KO

@warning_ignore("unused_parameter")
func _physics_process(delta):
	@warning_ignore("unused_variable")
	var direction = global_position.direction_to(player.global_position)
	direction.y = 0.0
	linear_velocity = direction * speed
	bat_model.rotation.y = Vector3.FORWARD.signed_angle_to(direction, Vector3.UP) + PI
	


func take_damage():
	if health == 0:
		return
	bat_model.hurt()
	
	health -= 1
	hurt.play()
	
	if health == 0:
		set_physics_process(false)
		gravity_scale = 1.0
		@warning_ignore("unused_variable")
		var direction = global_position.direction_to(player.global_position) * -1.0
		@warning_ignore("unused_variable")
		var random_upward_force = Vector3.UP * randf_range(1.0, 5)
		apply_central_impulse(direction * 15.0 + random_upward_force)
		timer.start()
		died.emit()
		ko.play()


func _on_timer_timeout() -> void:
	queue_free()
