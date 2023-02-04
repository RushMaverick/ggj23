extends Label

var score = 0


func _on_world_child_exiting_tree(node):
	if node.is_in_group("enemy"):
		score += 1
		self.text = str("Score = " , score)
