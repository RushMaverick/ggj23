extends Node3D

@export var target: Node3D
@export var min_pitch_deg = -30
@export var max_pitch_deg = 30
@export var sensitivity = 0.01

var mouse_delta = Vector2.ZERO
var player_moved = false

func _physics_process(_delta):
	if target:
		position = target.position
	if mouse_delta != Vector2.ZERO:
		rotation.x -= mouse_delta.y * sensitivity
		rotation.y -= mouse_delta.x * sensitivity
		rotation.x = clamp(rotation.x, deg_to_rad(min_pitch_deg), deg_to_rad(max_pitch_deg))
	if player_moved:
		target.rotation.y = rotation.y
		player_moved = false
	else:
		rotation.y -= mouse_delta.x * sensitivity
	mouse_delta = Vector2.ZERO

func _input(event):
	if event is InputEventMouseMotion:
		mouse_delta = event.relative

func set_yaw(angle):
	rotation.y = angle

func _on_player_moved():
	player_moved = true
