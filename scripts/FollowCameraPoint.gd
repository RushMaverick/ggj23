extends Node3D

@export var sensitivity = 0.1

@export var min_pitch_deg = -30
@export var max_pitch_deg = 0


var mouse_delta = Vector2.ZERO

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
		rotation.x = clamp(rotation.x, deg_to_rad(min_pitch_deg), deg_to_rad(max_pitch_deg))
		mouse_delta = Vector2.ZERO

func _input(event):
	if event is InputEventMouseMotion:
		mouse_delta = event.relative
	if event is InputEventMouseButton:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
