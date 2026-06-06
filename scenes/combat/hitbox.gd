extends Area3D

@export var damage := 1
@export var cooldown := 0.5

var hit_cooldown := {}


func _ready():
	area_entered.connect(_on_area_entered)


func _on_area_entered(area: Area3D):
	if not area.is_in_group("hurtbox"):
		return

	if not area.has_method("take_damage"):
		return

	if hit_cooldown.has(area):
		return

	area.take_damage(damage, global_position)
	_start_cooldown(area)


func _start_cooldown(area: Area3D):
	hit_cooldown[area] = true
	await get_tree().create_timer(cooldown).timeout
	hit_cooldown.erase(area)
