extends CharacterBody3D

signal health_changed(new_health)
signal stamina_changed(new_stamina)
signal enemy_target_set
signal enemy_target_unset

@export var max_health = 100
@export var max_stamina = 100
@export var stamina_recovery_rate = 10
@export var movement_speed = 300
@export var damage = 15
@export var hit_stamina_deduction = 15
@export var roll_stamina_deduction = 30
@export var hit_cooldown_ms = 400
@export var lerp_speed = 10
@export var weight = 300
@export var jumping_momentum = 0
@export var is_jumping: bool = false

var health = max_health
var stamina = max_stamina

var enemies_in_hurtbox = []
var enemies_in_range = []
var prev_hit_time = 0
var yaw
var target_yaw
var target_enemy = null
var is_rolling: bool
var is_falling: bool = false
var is_running: bool = false
var falling_momentum = 0
var sound_pain = []
var sound_grunt = []

func _ready():
	yaw = rotation.y
	target_yaw = rotation.y
	sound_pain.append($Sounds/Pain/TurnipPain1)
	sound_pain.append($Sounds/Pain/TurnipPain2)
	sound_pain.append($Sounds/Pain/TurnipPain3)
	sound_pain.append($Sounds/Pain/TurnipPain4)
	sound_grunt.append($Sounds/Attack/TurnipGrunt1)
	sound_grunt.append($Sounds/Attack/TurnipGrunt2)
	sound_grunt.append($Sounds/Attack/TurnipGrunt3)
	sound_grunt.append($Sounds/Attack/TurnipGrunt4)
	sound_grunt.append($Sounds/Attack/TurnipGrunt5)
	sound_grunt.append($Sounds/Attack/TurnipGrunt6)
	sound_grunt.append($Sounds/Attack/TurnipGrunt7)

func _input(event):
	if event.is_action_released("lock_enemy") and target_enemy:
		unset_target_enemy()
	if event.is_action_pressed("attack") and not is_rolling:
		attack()
	if event.is_action_pressed("roll") and not is_rolling and not is_jumping:
		roll()
	if event.is_action_pressed("jump") && not is_rolling and not is_jumping:
		jump()

func _process(delta):
	stamina = clamp(stamina + stamina_recovery_rate * delta, 0, max_stamina)
	emit_signal("stamina_changed", stamina)

func _physics_process(delta):
	var direction = get_movement_direction()
	var target_angle = $Turnip.rotation.y
	if !target_enemy and Input.is_action_pressed("lock_enemy"):
		find_target_enemy()
	if direction != Vector3.ZERO:
		if !is_running:
			is_running = true
			if $AnimationPlayer.current_animation == "Idle":
				$AnimationPlayer.play("Run")
		direction = direction.normalized()
		velocity = direction * movement_speed * delta
		velocity = velocity.rotated(Vector3.UP, rotation.y)
		target_angle = atan2(direction.x, direction.z)
		target_yaw = yaw
	if !target_enemy:
		$Turnip.rotation.y = lerp_angle($Turnip.rotation.y, target_angle, delta * lerp_speed)
	else:
		var target_enemy_direction = global_position - target_enemy.global_position
		target_enemy_direction.normalized()
		target_yaw = atan2(target_enemy_direction.x, target_enemy_direction.z)
	rotation.y = lerp_angle(rotation.y, target_yaw, delta * lerp_speed)
	if direction == Vector3.ZERO:
		if is_running:
			is_running = false
			if $AnimationPlayer.current_animation == "Run":
				$AnimationPlayer.play("Idle")
		velocity = Vector3.ZERO
	if is_on_floor():
		if is_falling:
			falling_momentum = 0
			is_falling = false
	else:
		if not is_falling:
			is_falling = true
		if not is_jumping:
			falling_momentum += 0.05
			velocity.y -= weight * falling_momentum * delta
	if is_jumping:
		velocity.y = jumping_momentum
	move_and_slide()

func get_movement_direction():
	var direction = Vector3.ZERO
	if Input.is_action_pressed("forward"):
		direction.z -= 1
	if Input.is_action_pressed("back"):
		direction.z += 1
	if Input.is_action_pressed("left"):
		direction.x -= 1
	if Input.is_action_pressed("right"):
		direction.x += 1
	return direction

func find_target_enemy():
	if enemies_in_range.is_empty():
		return
	var new_target = enemies_in_range.front()
	if new_target:
		var prev_distance = global_position - new_target.global_position
		for enemy in enemies_in_range:
			var distance = global_position - enemy.global_position
			if distance < prev_distance:
				new_target = enemy
				prev_distance = distance
		target_enemy = new_target
		$Turnip.rotation = Vector3.ZERO
		$Turnip.rotation.y = deg_to_rad(180)
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
		var rng = RandomNumberGenerator.new()
		rng.randomize()
		sound_grunt[rng.randi_range(0,6)].play()
		$AnimationPlayer.play("Attack")
		for enemy in enemies_in_hurtbox:
			if enemy: enemy.take_damage(damage)

func take_damage(amount):
	if is_rolling: return
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	sound_pain[rng.randi_range(0,3)].play()
	health = clamp(health - amount, 0, max_health)
	emit_signal("health_changed", health)
	if health <= 0:
		queue_free()
		get_tree().change_scene_to_file("res://scenes/StartScreen.tscn")

func jump():
	$AnimationPlayer.play("Local/jump_anim")

func roll():
	$AnimationPlayer.play("Roll")
	stamina -= roll_stamina_deduction
	stamina = clamp(stamina - roll_stamina_deduction, 0, max_stamina)
	emit_signal("stamina_changed", stamina)

func _on_hurtbox_body_entered(body):
	if (body.is_in_group("enemy")):
		enemies_in_hurtbox.append(body)

func _on_hurtbox_body_exited(body):
	if target_enemy == body:
		unset_target_enemy()
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

func _on_animation_player_animation_finished(anim_name):
	if anim_name == "Roll": is_rolling = false
	elif is_running: $AnimationPlayer.play("Run")
	else: $AnimationPlayer.play("Idle")

func _on_animation_player_animation_started(anim_name):
	if anim_name == "Roll": is_rolling = true
