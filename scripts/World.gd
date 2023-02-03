extends Node3D

@export var level_timer = 50000
@export var enemy_spawn_timer = 15000
var previous_level_up = 0
var prev_spawn_time = 0

var load_enemy = load("res://scenes/Enemy.tscn")

func _process(_delta):
	print(enemy_spawn_timer)
	if Time.get_ticks_msec() - previous_level_up > level_timer:
		if enemy_spawn_timer > 500:
			enemy_spawn_timer -= 500
		previous_level_up = Time.get_ticks_msec()
	if load_enemy:
		if Time.get_ticks_msec() - prev_spawn_time > enemy_spawn_timer:
			prev_spawn_time = Time.get_ticks_msec()
			var enemy = load_enemy.instantiate()
			enemy.position.x = randf_range(0, 10)
			enemy.position.z = randf_range(0, 10)
			enemy.position.y = 5
			add_child(enemy)
