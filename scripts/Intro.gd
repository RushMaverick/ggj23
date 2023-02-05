extends Node3D

func _ready():
	$Timer.start()

func _on_animation_player_animation_finished(_anim_name):
	get_tree().change_scene_to_file("res://scenes/NewMenu.tscn")

func _on_timer_timeout():
	$AnimationPlayer.play("Intro")
