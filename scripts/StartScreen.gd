extends Control

func _on_quit_pressed():
	get_tree().quit()

func _on_start_pressed():
	$IntroMusic.stop()
	get_tree().change_scene_to_file("res://scenes/Main.tscn")

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
