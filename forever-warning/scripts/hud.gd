extends Control

@onready var boss_life_gauge := $MarginContainer/BossLifeContainer/Control/BossLifeGauge
@onready var boss_life_text := $MarginContainer/BossLifeContainer/Control/BossLifeLabel
@onready var life_container := $LifeContainer
@onready var game_over := $GameOver

var life_icon := preload("res://scenes/hud/life_icon.tscn")

func _ready():
	game.hud = self
	reset()
	
func reset():
	game_over.visible = false
	set_lives(game.player_lives)
	
func clear_lives():
	for life in life_container.get_children():
		life.queue_free()

func set_lives(amount: int):
	clear_lives()
	for i in amount:
		var instance = life_icon.instantiate()
		life_container.add_child(instance)

func show_game_over():
	game_over.visible = true

func set_boss_life(life: int):
	boss_life_gauge.max_value = game.boss.total_life
	boss_life_gauge.value = game.boss.life
	var life_format_str = "%s/%s"
	var boss_life_str = str(clamp(game.boss.life, 0, game.boss.total_life))
	var boss_total_life_str = str(game.boss.total_life)
	boss_life_text.text = life_format_str % [boss_life_str, boss_total_life_str]
