extends Node2D

var is_occupied := false

func affect_weapon(weapon):
	add_child(weapon)
	weapon.position = Vector2.ZERO
	is_occupied = true
