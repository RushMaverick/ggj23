extends Node3D

@export var target: Node3D

func _physics_process(_delta):
	position = target.position
