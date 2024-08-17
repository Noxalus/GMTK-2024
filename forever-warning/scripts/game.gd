extends Node2D

var boss_core = preload("res://scenes/boss_core.tscn")
var boss_parts = [
	preload("res://scenes/boss_part_1.tscn"),
	preload("res://scenes/boss_part_2.tscn")
]

var rng = RandomNumberGenerator.new()
var wave_count: int = 0
var boss = null

func _ready():
	spawn_new_boss()

func spawn_new_boss():
	if boss == null:
		boss = boss_core.instantiate()
		get_tree().current_scene.add_child(boss)
		boss.died_signal.connect(_on_boss_death)
		boss.visible = false
	else:
		boss.setup()
	
	boss.position = Vector2(0, -175)

func _on_boss_death():
	spawn_new_boss()

func get_random_boss_part():
	return boss_parts[rng.randi_range(0, boss_parts.size() - 1)]
