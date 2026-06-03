extends Area3D

signal on_damage_taken(amount, attacker_pos)


func take_damage(amount: int, attacker_pos: Vector3):
	on_damage_taken.emit(amount, attacker_pos)
