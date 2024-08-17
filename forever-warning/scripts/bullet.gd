extends Area2D

@export var speed: float = 500

var direction: Vector2 = Vector2(0, 0)

func _physics_process(delta):
	position += direction * speed * delta
	
func set_direction(dir: Vector2):
	direction = dir
	rotation = direction.angle() + PI / 2.0
