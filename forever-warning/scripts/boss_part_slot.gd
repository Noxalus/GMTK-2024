extends Node2D

var is_occupied := false

func can_be_used():
	return not is_occupied

func affect_part(part):
	add_child(part)
	part.position = Vector2.ZERO
	is_occupied = true
