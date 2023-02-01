extends CharacterBody3D

@export var health = 50
@export var move_speed = 100
@export var damage = 10
@export var bite_distance = 100
@export var bite_cooldown_ms = 2000

var corpse_scene = preload("res://scenes/EnemyCorpse.tscn")

var prev_bite_time = 0
var target = null

func _process(_delta):
	if target \
		and global_position.distance_to(target.global_position) < bite_distance \
		and Time.get_ticks_msec() - prev_bite_time > bite_cooldown_ms:
		prev_bite_time = Time.get_ticks_msec()
		$AnimationPlayer.play("Bite")

func _physics_process(delta):
	if target:
		look_at(target.position, Vector3.UP)
		velocity = -global_transform.basis.z * move_speed * delta
	move_and_slide()

func take_damage(amount):
	health -= amount
	if health <= 0:
		var corpse = corpse_scene.instantiate()
		corpse.global_position = global_position
		corpse.rotation = rotation
		get_parent().add_child(corpse)
		queue_free()

func _on_hurtbox_body_entered(body):
	if body.is_in_group("player"):
		body.take_damage(damage)

func _on_vision_cone_body_entered(body):
	if body.is_in_group("player"):
		target = body

func _on_vision_cone_body_exited(body):
	if body.is_in_group("player"):
		target = null
