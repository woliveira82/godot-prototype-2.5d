extends CharacterBody3D

enum  FaceDirection {LEFT, RIGHT, UP, DOWN}

const SPEED = 6.0

@export var gravity = 12.0

var face_direction: FaceDirection = FaceDirection.DOWN

@onready var pivot = $CameraPivot
@onready var sprite = $AnimatedSprite3D


func _process(delta):
	pivot.global_position = global_position + Vector3(0, 1.5, 0)


func _physics_process(delta):
	# gravidade
	if not is_on_floor():
		velocity.y -= gravity * delta

	# input simples (WASD direto no mundo)
	var input_dir = Input.get_vector("left", "right", "up", "down").normalized()
	set_animation(input_dir)
	var direction = Vector3(input_dir.x, 0, input_dir.y)

	if direction != Vector3.ZERO:
		direction = direction.normalized()
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()


func set_animation(input_dir: Vector2):
	if abs(input_dir.x) > abs(input_dir.y):
		if input_dir.x > 0:
			sprite.play("idle_right")
		else:
			sprite.play("idle_left")
	else:
		if input_dir.y > 0:
			sprite.play("idle_down")
		else:
			sprite.play("idle_up")
