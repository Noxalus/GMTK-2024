extends Node2D

@export var boss_spawn_delay := 3.0

@onready var boss_spawn_timer = $BossSpawnTimer

var boss_core = preload("res://scenes/boss_core.tscn")

var wave_count: int = 0
var boss = null

func _ready():
	spawn_new_boss()

func _process(_delta):
	if boss != null and not boss.is_alive() and boss_spawn_timer.is_stopped():
		spawn_new_boss()

func spawn_new_boss():
	if boss == null:
		boss = boss_core.instantiate()
		get_tree().current_scene.add_child(boss)
		boss.died_signal.connect(_on_boss_death)
	boss.position = Vector2(0, -175)
	boss.setup(wave_count)

func _on_boss_death():
	boss_spawn_timer.start(boss_spawn_delay)
