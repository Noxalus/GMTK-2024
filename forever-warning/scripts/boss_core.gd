extends Area2D

@export var life: int = 20

func damage(amount: int):
	life -= amount
	if life < 0:
		queue_free()
