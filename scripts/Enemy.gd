extends CharacterBody3D

@export var move_speed = 20


func _physics_process(delta):
	velocity = Vector3.FORWARD * move_speed * delta
	velocity = velocity.rotated(Vector3.UP, rotation.y)
	move_and_slide()
	look_at_from_position(transform.origin, )
