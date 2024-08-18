extends Button

@onready var ico: TextureRect = $MarginContainer/Content/Icon
@onready var label: Label = $MarginContainer/Content/Label

var upgrade: Upgrade

func initialize(up: Upgrade):
	upgrade = up
	# update UI
	ico.texture = upgrade.icon
	label.text = upgrade.description

func _on_pressed() -> void:
	game.active_bonus(upgrade)
