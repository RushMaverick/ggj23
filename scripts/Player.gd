extends CharacterBody3D

signal health_changed(new_health)
signal stamina_changed(new_stamina)
signal enemy_target_set
signal enemy_target_unset

@export var max_health = 100
@export var max_stamina = 100
@export var stamina_recovery_rate = 5
@export var movement_speed = 150
@export var damage = 15
@export var hit_stamina_deduction = 10
@export var hit_cooldown_ms = 400
@export var lerp_speed = 7

var health = max_health
var stamina = max_stamina

var enemies_in_hurtbox = []
var enemies_in_range = []
var prev_hit_time = 0
var yaw
var target_yaw
var target_enemy = null

func _ready():
	yaw = rotation.y
	$AnimationPlayer.play("Idle")
	target_yaw = rotation.y

func _process(delta):
	stamina += stamina_recovery_rate * delta
	clamp(stamina, 0, max_stamina)
	emit_signal("stamina_changed", stamina)

func _physics_process(delta):
	var direction = Vector3.ZERO
	var target_angle = $Turnip.rotation.y
	if !target_enemy and Input.is_action_pressed("lock_enemy"):
		find_target_enemy()
	elif target_enemy and Input.is_action_just_released("lock_enemy"):
		unset_target_enemy()
	if Input.is_action_just_pressed("attack"):
		attack()
	if Input.is_action_pressed("forward"):
		direction.z -= 1
	if Input.is_action_pressed("back"):
		direction.z += 1
	if Input.is_action_pressed("left"):
		direction.x -= 1
	if Input.is_action_pressed("right"):
		direction.x += 1
	if direction != Vector3.ZERO:
		direction = direction.normalized()
		velocity = direction * movement_speed * delta
		velocity = velocity.rotated(Vector3.UP, rotation.y)
		target_angle = atan2(direction.x, direction.z)
		target_yaw = yaw
		move_and_slide()
		if $AnimationPlayer.current_animation != "Attack":
			$AnimationPlayer.play("Run")	
	elif $AnimationPlayer.current_animation != "Attack":
		$AnimationPlayer.play("Idle")
	$Turnip.rotation.y = lerp_angle($Turnip.rotation.y, target_angle, delta * lerp_speed)
	if !target_enemy:
		rotation.y = lerp_angle(rotation.y, target_yaw, delta * lerp_speed)
	else:
		var target_enemy_direction = global_position - target_enemy.global_position
		target_enemy_direction.normalized()
		rotation.y = atan2(target_enemy_direction.x, target_enemy_direction.z)

func find_target_enemy():
	var new_target = enemies_in_range.front()
	if new_target:
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
		clamp(stamina, 0, max_stamina)
		emit_signal("stamina_changed", stamina)
		$AnimationPlayer.play("Attack")
		for enemy in enemies_in_hurtbox:
			enemy.take_damage(damage)

func take_damage(amount):
	health -= amount
	clamp(health, 0, max_health)
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
