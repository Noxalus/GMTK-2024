extends Node

class_name Upgrade

var icon: Texture2D
var description: String
var effect: Callable
var is_available: Callable

func _init(ico: Texture2D, desc: String, eff: Callable, is_avail: Callable):
	icon = ico
	description = desc
	effect = eff
	is_available = is_avail

func execute_effect():
	effect.call()

func check_is_available():
	return is_available.call()
