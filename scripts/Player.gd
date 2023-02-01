extends CharacterBody3D

@export var movement_speed = 150
@export var health = 100
@export var stamina = 100
@export var damage = 20

var enemies_in_hurtbox = []

var yaw
var target_yaw

func _ready():
	$AnimationPlayer.play("Idle")
	target_yaw = rotation.y

func _physics_process(delta):
	var direction = Vector3.ZERO
	var target_angle = $Turnip.rotation.y
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
	$Turnip.rotation.y = lerp_angle($Turnip.rotation.y, target_angle, delta * 7)
	rotation.y = lerp_angle(rotation.y, target_yaw, delta * 7)

func attack():
	$AnimationPlayer.play("Attack")
	for enemy in enemies_in_hurtbox:
		enemy.take_damage(damage)

func take_damage(amount):
	health -= amount
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
