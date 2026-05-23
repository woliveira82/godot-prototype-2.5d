extends StaticBody3D

@export var hp := 5

@onready var sprite := $AnimatedSprite3D


func take_damage(amount: int):
	hp -= amount
	_hit_feedback()
	print("Dummy HP:", hp)
	if hp <= 0:
		queue_free()


func _hit_feedback():
	sprite.modulate = Color(1, 0.3, 0.3)
	sprite.scale = Vector3(1.1, 0.9, 1.0)
	await get_tree().create_timer(0.08).timeout
	sprite.modulate = Color.WHITE
	sprite.scale = Vector3.ONE
