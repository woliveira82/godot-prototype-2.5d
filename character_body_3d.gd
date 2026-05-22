extends CharacterBody3D

enum State {
	IDLE,
	WALK,
	ATTACK,
}

const FaceDirection = {
	UP = "up",
	DOWN = "down",
	LEFT = "left",
	RIGHT = "right",
}

@export var speed := 12.0
@export var gravity := 12.0

var facing: String = FaceDirection.DOWN
var input_dir := Vector2.ZERO
var wants_attack := false
var current_state := State.IDLE

@onready var pivot := $CameraPivot
@onready var sprite := $AnimatedSprite3D
@onready var hitbox := $Hitbox


func _ready():
	sprite.animation_finished.connect(_on_animation_finished)


func _physics_process(delta):
	_handle_input()
	_update_state()
	_handle_movement(delta)
	_update_animation()


func _handle_input():
	input_dir = Input.get_vector("left", "right", "up", "down")
	wants_attack = Input.is_action_just_pressed("attack")
	_update_facing_direction(input_dir)


func _update_state():
	if current_state == State.ATTACK:
		return

	if wants_attack:
		hitbox.monitoring = true
		current_state = State.ATTACK
		return

	if input_dir != Vector2.ZERO:
		current_state = State.WALK
	else:
		current_state = State.IDLE


func _handle_movement(delta):
	if not is_on_floor():
		velocity.y -= gravity * delta

	var direction = Vector3(input_dir.x, 0, input_dir.y)

	if direction != Vector3.ZERO:
		direction = direction.normalized()

	if current_state == State.WALK:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)

	move_and_slide()


func _update_animation():
	var anim := ""

	match current_state:
		State.IDLE:
			anim = "idle_" + facing

		State.WALK:
			anim = "run_" + facing

		State.ATTACK:
			anim = "atk_1_" + facing

	if sprite.animation != anim:
		sprite.play(anim)


func _update_facing_direction(dir: Vector2) -> void:
	if dir == Vector2.ZERO or current_state == State.ATTACK:
		return

	if abs(dir.x) > abs(dir.y):
		if dir.x > 0:
			facing = FaceDirection.RIGHT
			hitbox.position = Vector3(0.75, 0.5, 0.0)
		else:
			facing = FaceDirection.LEFT
			hitbox.position = Vector3(-0.75, 0.5, 0.0)

	else:
		if dir.y > 0:
			facing = FaceDirection.DOWN
			hitbox.position = Vector3(0.0, 0.5, 0.75)
		else:
			facing = FaceDirection.UP
			hitbox.position = Vector3(0.0, 0.5, -0.75)


func _on_animation_finished():
	if current_state == State.ATTACK:
		hitbox.monitoring = false
		if input_dir != Vector2.ZERO:
			current_state = State.WALK
		else:
			current_state = State.IDLE
