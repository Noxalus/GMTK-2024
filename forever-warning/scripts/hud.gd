extends Control

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
