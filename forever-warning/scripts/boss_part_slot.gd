extends Node2D

@export_range(0, 360, 0.001, "radians") var angle_amplitude: float = PI / 3.0

var is_occupied := false

func can_be_used():
	return not is_occupied

func affect_part(part):
	add_child(part)
	part.position = Vector2.ZERO
	is_occupied = true
