extends Node2D

func affect_weapon(weapon):
	add_child(weapon)
	weapon.position = Vector2.ZERO
