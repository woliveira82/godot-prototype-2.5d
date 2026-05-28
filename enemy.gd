extends CharacterBody3D

enum State {
	IDLE,
	CHASE,
	HURT,
	STUN,
	DEAD,
}

const FaceDirection = {
	UP = "up",
	DOWN = "down",
	LEFT = "left",
	RIGHT = "right",
}

@export var speed := 3.0
@export var gravity := 12.0
@export var max_hp := 5
@export var damage := 1
@export var knockback_force := 8.0

var hp := max_hp

var current_state := State.IDLE
var player : Node3D
var can_damage := true
var facing: String = FaceDirection.DOWN
var stun_time := 0.0
var knockback_velocity := Vector3.ZERO
var knockback := false

@onready var sprite := $VisualPivot/AnimatedSprite3D
@onready var visual := $VisualPivot
@onready var hitbox := $Hitbox


func _ready():
	player = get_tree().get_first_node_in_group("player")
	hitbox.body_entered.connect(_on_hitbox_body_entered)
	sprite.modulate = Color.WEB_GREEN


func _physics_process(delta):
	if current_state == State.DEAD:
		return

	if current_state == State.STUN:
		stun_time -= delta
		velocity.x += knockback_velocity.x
		velocity.z += knockback_velocity.z
		knockback_velocity = knockback_velocity.lerp(Vector3.ZERO, delta * 8.0)
		move_and_slide()

	_update_state()
	_handle_movement(delta)
	_update_animation()


func _update_state():
	if current_state == State.STUN:
		if stun_time > 0.0:
			return

	if current_state == State.HURT:
		return

	if current_state == State.DEAD:
		return

	if player == null:
		current_state = State.IDLE
		return

	current_state = State.CHASE


func _handle_movement(delta):
	if not is_on_floor():
		velocity.y -= gravity * delta

	if knockback:
		velocity.x += knockback_velocity.x * knockback_force
		velocity.z += knockback_velocity.z * knockback_force
		#knockback_velocity = knockback_velocity.lerp(Vector3.ZERO, delta * 8.0)

	if current_state == State.CHASE:
		var dir = (player.global_position - global_position).normalized()
		_update_facing(dir)
		velocity.x = dir.x * speed
		velocity.z = dir.z * speed

	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)

	move_and_slide()


func _update_facing(dir: Vector3) -> void:
	if abs(dir.x) > abs(dir.z):
		if dir.x > 0:
			facing = FaceDirection.RIGHT
		else:
			facing = FaceDirection.LEFT

	else:
		if dir.z > 0:
			facing = FaceDirection.DOWN
		else:
			facing = FaceDirection.UP


func _update_animation():
	var anim = ""
	match current_state:
		State.IDLE:
			anim = "idle_" + facing

		State.CHASE:
			anim = "run_" + facing

		State.STUN:
			anim = "idle_" + facing

		State.DEAD:
			anim = "idle_down"

	sprite.play(anim)


func take_damage(amount: int):
	if current_state == State.DEAD:
		return

	hp -= amount
	_hit_feedback()
	knockback_velocity = (global_position - player.global_position).normalized()

	current_state = State.STUN
	stun_time = 1.0
	knockback = true

	if hp <= 0:
		current_state = State.DEAD
		queue_free()


func _on_hitbox_body_entered(body):
	if not can_damage:
		return

	if body.has_method("take_damage"):
		body.take_damage(damage)
		can_damage = false
		await get_tree().create_timer(1.0).timeout
		can_damage = true


func _hit_feedback():
	sprite.modulate = Color(1, 0.3, 0.3)
	sprite.scale = Vector3(1.1, 0.9, 1.0)
	await get_tree().create_timer(0.2).timeout
	sprite.modulate = Color.WEB_GREEN
	sprite.scale = Vector3.ONE


func _on_hitbox_area_entered(area):
	var target = area.get_parent()

	if target.has_method("take_damage"):
		target.take_damage(1)
