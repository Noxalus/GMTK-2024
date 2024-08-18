extends Button

@onready var ico: TextureRect = $Content/Icon
@onready var label: Label = $Content/Label

var upgrade: Upgrade

func _ready() -> void:
	print("COUCOU")

func initialize(up: Upgrade):
	upgrade = up
	# update UI
	ico.texture = upgrade.icon
	label.text = upgrade.description

func _on_pressed() -> void:
	game.active_bonus(upgrade)
