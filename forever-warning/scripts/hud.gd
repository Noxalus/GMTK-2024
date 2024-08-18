extends Control

@onready var life_container := $LifeContainer

var life_icon := preload("res://scenes/hud/life_icon.tscn")

func _ready():
	game.hud = self
	set_lives(game.player_lives)
	
func clear_lives():
	for life in life_container.get_children():
		life.queue_free()

func set_lives(amount: int):
	clear_lives()
	for i in amount:
		var instance = life_icon.instantiate()
		life_container.add_child(instance)
