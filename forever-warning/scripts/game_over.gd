extends Control

@onready var line_edit: LineEdit = $VBoxContainer/LineEdit
@onready var check_button: CheckButton = $VBoxContainer/HBoxContainer/CheckButton

var use_custom_seed = false

func _ready() -> void:
	line_edit.visible = false
	line_edit.text = game.seed

func _on_restart_button_pressed():
	if use_custom_seed:
		game.seed = line_edit.text
	else:
		game.seed = game.generate_random_seed()
		
	game.restart()

func _on_check_button_toggled(toggled_on: bool) -> void:
		use_custom_seed = toggled_on
		line_edit.visible = use_custom_seed
