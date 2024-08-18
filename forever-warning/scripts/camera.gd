extends Camera2D

@export var shake_base_amount := 1.0
@export var shake_dampening := 0.075

var base_position: Vector2
var shake_amount := 0.0

func _init():
	base_position = position
	print(base_position)
	
func _ready():
	game.camera = self

func _process(delta):
	if game.is_paused:
		return
		
	if shake_amount > 0:
		position.x = base_position.x + randf_range(-shake_base_amount, shake_base_amount) * shake_amount
		position.y = base_position.y + randf_range(-shake_base_amount, shake_base_amount) * shake_amount
		shake_amount = lerp(shake_amount, 0.0, shake_dampening)
	else:
		position = base_position
	
func shake(amount: float):
	shake_amount += amount
