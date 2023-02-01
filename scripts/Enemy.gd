extends CharacterBody3D

@export var move_speed = 1

var target

var body_pos

func _physics_process(delta):
	if target:
		print(target.name)
		look_at(target.position, Vector3.UP)
		velocity = velocity.move_toward(Vector3.FORWARD * move_speed, delta)
		#This just moves the enemy FORWARD, we need to give a new Vector3 to the enemy node based on the player's position
	else:
		velocity = Vector3.FORWARD * move_speed
	move_and_slide()

func _on_area_3d_body_entered(body):
	target = body

func _on_area_3d_body_exited(body):
	target = null
