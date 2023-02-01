extends Control

@export var health_bar: Control
@export var stamina_bar: Control

func _on_player_health_changed(new_health):
	health_bar.value = new_health

func _on_player_stamina_changed(new_stamina):
	stamina_bar.value = new_stamina
