extends CharacterBody3D

@export var health = 50
@export var move_speed = 100
@export var damage = 40
@export var bite_distance = 1
@export var bite_cooldown_ms = 2000
@export var charge_distance = 6
@export var charge_cooldown_ms = 2000
@export var charge_movespeed_scalar = 2.0
@export var weight = 300

var corpse_scene = preload("res://scenes/EnemyCorpse.tscn")
var falling_momentum = 0
var random_position: Vector3 = Vector3(0,0,0)
var prev_bite_time = 0
var prev_charge_time = 0
var target = null
var random_vector_time = 6000
var previously_generated_vector_age = 0

func _process(_delta):
	if target:
		if global_position.distance_to(target.global_position) <= bite_distance:
			if Time.get_ticks_msec() - prev_bite_time > bite_cooldown_ms:
				prev_bite_time = Time.get_ticks_msec()
				$AnimationPlayer.play("Bite")
		elif global_position.distance_to(target.global_position) <= charge_distance:
			if Time.get_ticks_msec() - prev_charge_time > charge_cooldown_ms:
				prev_charge_time = Time.get_ticks_msec()
				$AnimationPlayer.play("Charge")
		elif $AnimationPlayer.current_animation == "Charge":
			$AnimationPlayer.play("Walk")

func _physics_process(delta):
	var rot_x = rotation.x
	if target:
		look_at(target.position, Vector3.UP)
		rotation.x = rot_x
		velocity = -global_transform.basis.z * move_speed * delta
		if $AnimationPlayer.current_animation == "Charge":
			velocity *= charge_movespeed_scalar
	else:
		if Time.get_ticks_msec() - previously_generated_vector_age > random_vector_time:
			previously_generated_vector_age = Time.get_ticks_msec()
			generate_random_vector()
		look_at(random_position, Vector3.UP)
		velocity = -global_transform.basis.z * move_speed * delta
	if !is_on_floor():
		fall(delta)
	move_and_slide()

func generate_random_vector():
	var x = randf_range(0, 10)
	var y = 0
	var z = randf_range(0, 10)
	random_position = Vector3(global_position.x * x, global_position.y * 1, global_position.z * z)
	
	
func take_damage(amount):
	health -= amount
	if health <= 0:
		var corpse = corpse_scene.instantiate()
		corpse.global_position = global_position
		corpse.rotation = rotation
		get_parent().add_child(corpse)
		queue_free()

func fall(delta):
	falling_momentum += 0.05
	velocity.y -= weight * falling_momentum * delta
	move_and_slide()

func _on_hurtbox_body_entered(body):
	if body.is_in_group("player"):
		body.take_damage(damage)

func _on_vision_cone_body_entered(body):
	if body.is_in_group("player"):
		target = body

func _on_vision_cone_body_exited(body):
	if body.is_in_group("player"):
		target = null
