extends CharacterBody3D

signal hp_changed(current_hp, max_hp)

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
@export var max_hp := 10
@export var knockback_force := 8.0
@export var invulnerability_time := 0.5

var hp := max_hp
var facing: String = FaceDirection.DOWN
var input_dir := Vector2.ZERO
var wants_attack := false
var current_state := State.IDLE
var knockback_velocity := Vector3.ZERO
var knockback_dir := Vector3.ZERO
var is_invulnerable := false

@onready var pivot := $CameraPivot
@onready var sprite := $AnimatedSprite3D
@onready var hitbox := $Hitbox


func _ready():
	sprite.animation_finished.connect(_on_animation_finished)
	$Hurtbox.on_damage_taken.connect(_take_damage)


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

	var direction := Vector3(input_dir.x, 0, input_dir.y)
	if direction != Vector3.ZERO:
		direction = direction.normalized()

	var move_x := 0.0
	var move_z := 0.0
	if current_state == State.WALK:
		move_x = direction.x * speed
		move_z = direction.z * speed

	velocity.x = move_x + knockback_velocity.x
	velocity.z = move_z + knockback_velocity.z
	knockback_velocity = knockback_velocity.lerp(Vector3.ZERO, delta * 10.0)
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


func _take_damage(amount: int, attacker_pos: Vector3):
	if is_invulnerable:
		return

	hp -= amount
	emit_signal("hp_changed", hp, max_hp)
	_hit_feedback()
	knockback_velocity = (position - attacker_pos).normalized() * knockback_force

	_start_invulnerability()

	if hp <= 0:
		queue_free()


func _start_invulnerability():
	is_invulnerable = true
	_blink_invulnerability()
	await get_tree().create_timer(invulnerability_time).timeout
	is_invulnerable = false
	sprite.visible = true


func _hit_feedback():
	sprite.modulate = Color.RED
	sprite.scale = Vector3(1.1, 0.9, 1.0)
	await get_tree().create_timer(0.2).timeout
	sprite.modulate = Color.WHITE
	sprite.scale = Vector3.ONE


func _blink_invulnerability():
	while is_invulnerable:
		sprite.visible = false
		await get_tree().create_timer(0.08).timeout
		sprite.visible = true
		await get_tree().create_timer(0.08).timeout
