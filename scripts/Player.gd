extends CharacterBody3D

@export var movement_speed = 5

func _ready():
	print("Hello")
	$AnimationPlayer.play("Idle")

func _physics_process(delta):
	var direction = Vector3.ZERO
	if Input.is_action_pressed("forward"):
		direction.z -= 1
	if Input.is_action_pressed("back"):
		direction.z += 1
	if Input.is_action_pressed("left"):
		direction.x -= 1
	if Input.is_action_pressed("right"):
		direction.x += 1
	if direction != Vector3.ZERO:
		direction = direction.normalized()
		$AnimationPlayer.play("Run")
		look_at(position + direction, Vector3.UP)
	else:
		$AnimationPlayer.play("Idle")
	velocity.x = direction.x * movement_speed
	velocity.z = direction.z * movement_speed
	move_and_slide()
