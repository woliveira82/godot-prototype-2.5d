extends Node3D

@export var enemy_scene: PackedScene
@export var spawn_interval := 2.0
@export var max_enemies := 20

@onready var enemy_container := %Enemies
@onready var spawner_points := get_children()


func _ready():
	spawn_loop()


func spawn_loop() -> void:
	while true:
		await get_tree().create_timer(spawn_interval).timeout
		if enemy_container.get_child_count() >= max_enemies:
			continue

		spawn_enemy()


func spawn_enemy() -> void:
	var enemy = enemy_scene.instantiate()
	var spawner_point: Node3D = spawner_points.pick_random()
	enemy_container.add_child(enemy)
	enemy.global_position = spawner_point.global_position
