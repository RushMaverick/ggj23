extends Node3D

@export var target: Node3D

func _physics_process(_delta):
	if target:
d		position = target.position
