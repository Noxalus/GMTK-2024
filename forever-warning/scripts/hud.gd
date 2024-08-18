extends Control

@onready var boss_life_gauge := $MarginContainer/BossLifeContainer/Control/BossLifeGauge
@onready var boss_life_text := $MarginContainer/BossLifeContainer/Control/BossLifeLabel
@onready var boss_label := $MarginContainer/BossLifeContainer/BossLabel
@onready var life_container := $LifeContainer
@onready var game_over := $GameOver
@onready var upgrades: Control = $Upgrades
@onready var upgrades_container: HBoxContainer = $Upgrades/UpgradesContainer

const UPGRADE_CARD = preload("res://scenes/upgrade_card.tscn")

var life_icon := preload("res://scenes/hud/life_icon.tscn")

func _ready():
	game.hud = self
	reset()
	
func reset():
	game_over.visible = false
	upgrades.visible = false
	refresh_player_lives()
	set_wave_count(game.wave_count)
	
func clear_lives():
	for life in life_container.get_children():
		life.queue_free()

func refresh_player_lives():
	set_lives(game.player_lives)

func set_lives(amount: int):
	clear_lives()
	for i in amount:
		var instance = life_icon.instantiate()
		life_container.add_child(instance)

func show_game_over():
	game_over.visible = true

func clear_upgrades():
	for upgrade in upgrades_container.get_children():
		upgrade.queue_free()

func show_upgrades():
	game.pause()
	clear_upgrades()
	upgrades.visible = true
	
	var random_upgrades = game.get_random_upgrades(2)
	for upgrade in random_upgrades:
		var instance = UPGRADE_CARD.instantiate()
		upgrades_container.add_child(instance)
		instance.initialize(upgrade)

func hide_upgrades():
	game.unpause()
	clear_upgrades()
	upgrades.visible = false

func set_boss_life(life: int):
	boss_life_gauge.max_value = game.boss.total_life
	boss_life_gauge.value = game.boss.life
	var life_format_str = "%s/%s"
	var boss_life_str = str(clamp(game.boss.life, 0, game.boss.total_life))
	var boss_total_life_str = str(game.boss.total_life)
	boss_life_text.text = life_format_str % [boss_life_str, boss_total_life_str]

func set_wave_count(count: int):
	boss_label.text = "BOSS\n#%s" % count
