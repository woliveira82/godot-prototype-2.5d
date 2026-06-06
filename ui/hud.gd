extends CanvasLayer

@onready var player := get_tree().get_first_node_in_group("player")
@onready var hp_bar := $MarginContainer/VBoxContainer/ProgressBar


func _ready():
	player.hp_changed.connect(_on_hp_changed)


func _on_hp_changed(current_hp: int, max_hp: int):
	hp_bar.max_value = max_hp
	hp_bar.value = current_hp
	flash_hp_bar()


func flash_hp_bar():
	hp_bar.modulate = Color.WHITE
	await get_tree().create_timer(0.08).timeout
	hp_bar.modulate = Color.RED
