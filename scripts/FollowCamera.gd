extends Node3D

@export var target: Node3D
@export var min_pitch_deg = -30
@export var max_pitch_deg = 10
@export var sensitivity = 0.005

signal moved(angle)

enum CAMERA_MODE {FOLLOW, TARGET}
var camera_mode = CAMERA_MODE.FOLLOW

var mouse_delta = Vector2.ZERO

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _physics_process(_delta):
	if target:
		position = target.position
	if camera_mode == CAMERA_MODE.FOLLOW:
		if mouse_delta != Vector2.ZERO:
			rotation.x -= mouse_delta.y * sensitivity
			rotation.y -= mouse_delta.x * sensitivity
			rotation.x = clamp(rotation.x, deg_to_rad(min_pitch_deg), deg_to_rad(max_pitch_deg))
			emit_signal("moved", self.rotation.y)
		else:
			rotation.y -= mouse_delta.x * sensitivity
	else:
		rotation.y = target.rotation.y
	mouse_delta = Vector2.ZERO

func _input(event):
	if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		if Input.is_action_just_pressed("ui_cancel"):
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		elif event is InputEventMouseMotion:
			mouse_delta = event.relative
	elif Input.is_action_just_pressed("attack"):
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _on_player_enemy_target_set():
	camera_mode = CAMERA_MODE.TARGET

func _on_player_enemy_target_unset():
	camera_mode = CAMERA_MODE.FOLLOW
