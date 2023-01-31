extends Node3D

@export var sensitivity = 0.3

var mouse_delta = Vector2.ZERO
var camera_min_angle = -0.8
var camera_max_angle = 0.8

var player

func _ready():
	player = get_node("../Player")
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _process(delta):
	position.x = player.position.x
	position.z = player.position.z
	if Input.is_action_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		rotation.x -= mouse_delta.y * sensitivity * delta
		rotation.y -= mouse_delta.x * sensitivity * delta
		rotation.x = clamp(rotation.x, camera_min_angle, camera_max_angle)
		rotation.y = clamp(rotation.y, camera_min_angle, camera_max_angle)
		mouse_delta = Vector2.ZERO

func _input(event):
	if event is InputEventMouseMotion:
		mouse_delta = event.relative
	if event is InputEventMouseButton:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
