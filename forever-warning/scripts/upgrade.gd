extends Node

class_name Upgrade

var icon: Texture2D
var description: String
var effect: Callable

func _init(ico: Texture2D, desc: String, eff: Callable):
	icon = ico
	description = desc
	effect = eff

func execute_effect():
	effect.call()
