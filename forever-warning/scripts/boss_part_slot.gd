extends Node2D

var is_occupied := false

func can_be_used():
	return not is_occupied

func affect_part(part):
	#part.get_parent().remove_child(self)
	add_child(part)
	is_occupied = true
