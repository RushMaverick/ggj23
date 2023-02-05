extends CharacterBody3D

@export var health = 50
@export var move_speed_walk = 100
@export var move_speed_charge = 200
@export var damage = 5
@export var bite_distance = 1
@export var charge_distance = 6
@export var weight = 300

var corpse_scene = preload("res://scenes/EnemyCorpse.tscn")
var falling_momentum = 0
var prev_bite_time = 0
var prev_charge_time = 0
var target = null
var random_vector_time = 5000
var previously_generated_vector_age = 0
var target_yaw
var move_speed
var can_attack: bool = false

func _ready():
	target_yaw = rotation.y
	move_speed = move_speed_walk
	$ChangeDirectionTimer.start()

func _physics_process(delta):
	if target:
		var rot_x = rotation.x
		look_at(target.position, Vector3.UP)
		rotation.x = rot_x
		if can_attack:
			if global_position.distance_to(target.global_position) <= bite_distance:
				$AnimationPlayer.play("Bite")
				can_attack = false
				$AttackCooldownTimer.start()
			elif global_position.distance_to(target.global_position) <= charge_distance:
				$AnimationPlayer.play("Charge")
				can_attack = false
				$AttackCooldownTimer.start()
	else:
		rotation.y = lerp_angle(rotation.y, target_yaw, delta * 10)
	velocity = -global_transform.basis.z * move_speed * delta
	if !is_on_floor():
		fall(delta)
	else:
		falling_momentum = 0
	move_and_slide()

func take_damage(amount):
	$Damage.play()
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
		$ChangeDirectionTimer.stop()
		$AttackCooldownTimer.start()

func _on_vision_cone_body_exited(body):
	if body.is_in_group("player"):
		target = null
		$ChangeDirectionTimer.start()
		$AttackCooldownTimer.stop()

func _on_animation_player_animation_finished(anim_name):
	if anim_name == "Charge":
		move_speed = move_speed_walk
	$AnimationPlayer.play("Walk")

func _on_animation_player_animation_started(anim_name):
	if anim_name == "Charge":
		move_speed = move_speed_charge

func _on_change_direction_timer_timeout():
	target_yaw = randf_range(0, 10) / randf_range(0, 10) * 3.14
	$ChangeDirectionTimer.start()

func _on_attack_cooldown_timer_timeout():
	can_attack = true
