extends CharacterBody3D

signal health_changed(new_health)
signal stamina_changed(new_stamina)
signal enemy_target_set
signal enemy_target_unset

@export var max_health = 100
@export var max_stamina = 100
@export var stamina_recovery_rate = 5
@export var movement_speed = 300
@export var damage = 15
@export var hit_stamina_deduction = 5
@export var hit_cooldown_ms = 400
@export var lerp_speed = 10
@export var gravity = 300

var health = max_health
var stamina = max_stamina

var enemies_in_hurtbox = []
var enemies_in_range = []
var prev_hit_time = 0
var yaw
var target_yaw
var target_enemy = null
var is_rolling: bool

func _ready():
	yaw = rotation.y
	target_yaw = rotation.y

func _process(delta):
	stamina = clamp(stamina + stamina_recovery_rate * delta, 0, max_stamina)
	emit_signal("stamina_changed", stamina)

func _physics_process(delta):
	var direction = Vector3.ZERO
	var target_angle = $Turnip.rotation.y
	if !target_enemy and Input.is_action_pressed("lock_enemy"):
		find_target_enemy()
	elif target_enemy and Input.is_action_just_released("lock_enemy"):
		unset_target_enemy()
	if Input.is_action_just_pressed("attack") && not is_rolling:
		attack()
	elif Input.is_action_just_pressed("roll") && not is_rolling:
		$AnimationPlayer.play("Roll")
	if Input.is_action_pressed("forward"):
		direction.z -= 1
	if Input.is_action_pressed("back"):
		direction.z += 1
	if Input.is_action_pressed("left"):
		direction.x -= 1
	if Input.is_action_pressed("right"):
		direction.x += 1
	if direction != Vector3.ZERO and is_on_floor():
		direction = direction.normalized()
		velocity = direction * movement_speed * delta
		velocity = velocity.rotated(Vector3.UP, rotation.y)
		target_angle = atan2(direction.x, direction.z)
		target_yaw = yaw
		move_and_slide()
		if $AnimationPlayer.current_animation not in ["Attack", "Roll"]:
			$AnimationPlayer.play("Run")	
	elif $AnimationPlayer.current_animation not in ["Attack", "Roll"]:
		$AnimationPlayer.play("Idle")
	if !is_on_floor():
		velocity.y -= gravity * delta
		move_and_slide()
	$Turnip.rotation.y = lerp_angle($Turnip.rotation.y, target_angle, delta * lerp_speed)
	if target_enemy:
		var target_enemy_direction = global_position - target_enemy.global_position
		target_enemy_direction.normalized()
		target_yaw = atan2(target_enemy_direction.x, target_enemy_direction.z)
	rotation.y = lerp_angle(rotation.y, target_yaw, delta * lerp_speed)
	

func find_target_enemy():
	var new_target = enemies_in_range.front()
	if new_target:
		var prev_distance = global_position - new_target.global_position
		for enemy in enemies_in_range:
			var distance = global_position - enemy.global_position
			if distance < prev_distance:
				new_target = enemy
				prev_distance = distance
		target_enemy = new_target
		emit_signal("enemy_target_set")

func unset_target_enemy():
	target_enemy = null
	emit_signal("enemy_target_unset")

func attack():
	if Time.get_ticks_msec() - prev_hit_time > hit_cooldown_ms \
		and stamina >= hit_stamina_deduction:
		prev_hit_time = Time.get_ticks_msec()
		stamina -= hit_stamina_deduction
		stamina = clamp(stamina - hit_stamina_deduction, 0, max_stamina)
		emit_signal("stamina_changed", stamina)
		$AnimationPlayer.play("Attack")
		for enemy in enemies_in_hurtbox:
			enemy.take_damage(damage)

func take_damage(amount):
	if is_rolling: return
	health = clamp(health - amount, 0, max_health)
	emit_signal("health_changed", health)
	if health <= 0:
		queue_free()

func _on_hurtbox_body_entered(body):
	if (body.is_in_group("enemy")):
		enemies_in_hurtbox.append(body)

func _on_hurtbox_body_exited(body):
	if body in enemies_in_hurtbox:
		enemies_in_hurtbox.erase(body)

func _on_follow_camera_moved(angle):
	yaw = angle

func _on_target_range_body_entered(body):
	if body.is_in_group("enemy"):
		enemies_in_range.append(body)

func _on_target_range_body_exited(body):
	if body in enemies_in_range:
		enemies_in_range.erase(body)

func _on_animation_player_animation_started(anim_name):
	if anim_name == "Roll": is_rolling = true

func _on_animation_player_animation_finished(anim_name):
	if anim_name == "Roll": is_rolling = false
