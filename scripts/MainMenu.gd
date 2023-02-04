extends Node3D

@export var hover_animation_speed = 10
@export var hover_animation_scale = 0.1

var start_z: float = 0.0
var quit_z: float  = 0.0

var is_start_hovered: bool = false
var is_quit_hovered: bool = false

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _input(event):
	if event.is_action_pressed("attack") and is_quit_hovered:
		get_tree().quit()
	if event.is_action_pressed("attack") and is_start_hovered:
		get_tree().change_scene_to_file("res://scenes/Main.tscn")

func _physics_process(delta):
	$StartGameMenuItem.position.z = lerp($StartGameMenuItem.position.z, start_z, hover_animation_speed * delta)
	$QuitMenuItem.position.z = lerp($QuitMenuItem.position.z, quit_z, hover_animation_speed * delta)

func _on_start_game_menu_item_mouse_entered():
	is_start_hovered = true
	start_z = hover_animation_scale

func _on_start_game_menu_item_mouse_exited():
	is_start_hovered = false
	start_z = 0.0

func _on_quit_menu_item_mouse_entered():
	is_quit_hovered = true
	quit_z = hover_animation_scale

func _on_quit_menu_item_mouse_exited():
	is_quit_hovered = false
	quit_z = 0.0
