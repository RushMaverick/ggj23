extends CharacterBody3D

@export var move_speed = 20

@onready var cyl = $ShapeCast3D

func _physics_process(delta):
	velocity = Vector3.FORWARD * move_speed * delta
	velocity = velocity.rotated(Vector3.UP, rotation.y)
	move_and_slide()

func _process(_delta):
	for	body in get_tree().get_nodes_in_group("target_to_attack"):
		var _body_pos = body.global_transform.origin

func _on_area_3d_body_entered(body):
	print(body)
