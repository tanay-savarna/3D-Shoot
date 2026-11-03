extends Node3D

var player_score = 0
@onready var label = %Label

func increase_score():
	player_score += 1
	label.text = "Score: " + str(player_score)


func _on_mob_spawner_3d_mob_spawned(mob: Variant) -> void:
	mob.died.connect(increase_score)


func _on_mob_spawner_3d_2_mob_spawned(mob: Variant) -> void:
	mob.died.connect(increase_score)


@warning_ignore("unused_parameter")
func _on_kill_plane_body_entered(body: Node3D) -> void:
	get_tree().reload_current_scene.call_deferred()
