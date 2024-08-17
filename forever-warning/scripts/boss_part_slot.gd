extends Node2D

@export_range(-360, 360, 0.001, "radians") var base_random_angle_min: float = 0
@export_range(-360, 360, 0.001, "radians") var base_random_angle_max: float = 0
@export_range(0, 360, 0.001, "radians") var angle_amplitude: float = PI / 3.0

@onready var boss_part = $"../.."

var is_occupied := false

func affect_part(part):
	add_child(part)
	part.position = Vector2.ZERO
	is_occupied = true

func get_related_part():
	if boss_part is BossPart:
		return  boss_part
	return null
