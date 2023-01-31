extends Camera3D

var player

func _ready():
	player = get_node("../Player")

func _process(delta):
	position.x = player.position.x
	position.z = player.position.z + 1.5
