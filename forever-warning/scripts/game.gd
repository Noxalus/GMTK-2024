extends Node2D

var boss_core = preload("res://scenes/boss_core.tscn")

var wave_count: int = 0
var boss = null

func _ready():
	spawn_new_boss()

func _process(delta):
	pass

func spawn_new_boss():
	if boss == null:
		boss = boss_core.instantiate()
		get_tree().current_scene.add_child(boss)
	boss.position = Vector2(0, -175)
	boss.setup(wave_count)
