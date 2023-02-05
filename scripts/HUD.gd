extends Control

@export var health_bar: Control
@export var stamina_bar: Control

var score = 0

func _on_player_health_changed(new_health):
	health_bar.value = new_health

func _on_player_stamina_changed(new_stamina):
	stamina_bar.value = new_stamina

func increase_score():
	score += 1
	$PlayerStatus/HBoxContainer/VBoxContainer/RichTextLabel.text = str("Beetles borked: ", score)
