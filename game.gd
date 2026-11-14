extends Node3D

var player_score = 0
var next_reward = 10

@onready var label = %Label
@onready var label2 = %Label2
const SMOKE_PUFF = preload("res://mob/smoke_puff/smoke_puff.tscn")

func increase_score():
	player_score += 1
	label.text = "Score: " + str(player_score)
	if player_score >= next_reward:
		give_reward()
		next_reward += 10

func give_reward():
	%Player.rapid_fire_charges += 1

	if player_score % 20 == 0:
		%Player.jetpack_charges += 1
		
	if player_score % 30 == 0:
		%Player.speed_boost_charges += 1

	%Player.update_ability_buttons()


func do_poof(mob_global_position: Vector3):
	var poof = SMOKE_PUFF.instantiate()
	add_child(poof)
	poof.global_position = mob_global_position

func _on_mob_spawner_3d_mob_spawned(mob: Variant) -> void:
	# Instant score update when killed
	mob.killed.connect(func on_mob_killed():
		increase_score()
	)
	
	# Delayed smoke poof when it finally despawns
	mob.despawned.connect(func on_mob_despawned(final_pos: Vector3):
		do_poof(final_pos)
	)
	
	# Spawn poof happens immediately when the mob appears
	do_poof(mob.global_position)

func _on_mob_spawner_3d_2_mob_spawned(mob: Variant) -> void:
	#  Instant score update when killed
	mob.killed.connect(func on_mob_killed():
		increase_score()
	)
	
	#  Delayed smoke poof when it finally despawns
	mob.despawned.connect(func on_mob_despawned(final_pos: Vector3):
		do_poof(final_pos)
	)
	
	# Spawn poof happens immediately when the mob appears
	do_poof(mob.global_position)

@warning_ignore("unused_parameter")
func _on_kill_plane_body_entered(body: Node3D) -> void:
	get_tree().reload_current_scene.call_deferred()
