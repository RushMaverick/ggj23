extends CharacterBody3D

@export var movement_speed = 5
@export var sensitivity = 0.1
@export var min_pitch_deg = -30
@export var max_pitch_deg = 0

var mouse_delta = Vector2.ZERO

func _ready():
	print("Hello")
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	$AnimationPlayer.play("Idle")

func _physics_process(delta):
	var direction = Vector3.ZERO
	if Input.is_action_pressed("forward"):
		direction.z -= 1
		$Turnip.rotation.y = deg_to_rad(-180)
	if Input.is_action_pressed("back"):
		direction.z += 1
		$Turnip.rotation.y = deg_to_rad(0)
	if Input.is_action_pressed("left"):
		direction.x -= 1
		$Turnip.rotation.y = deg_to_rad(-90)
	if Input.is_action_pressed("right"):
		direction.x += 1
		$Turnip.rotation.y = deg_to_rad(90)
	if direction != Vector3.ZERO:
		direction = direction.normalized()
		$AnimationPlayer.play("Run")
		

	else:
		$AnimationPlayer.play("Idle")
	velocity.x = direction.x * movement_speed
	velocity.z = direction.z * movement_speed
	velocity = velocity.rotated(Vector3.UP, rotation.y)
	
	move_and_slide()

func _process(delta):
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
