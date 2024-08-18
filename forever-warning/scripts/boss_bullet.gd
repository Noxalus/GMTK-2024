extends Area2D

@export var base_speed: float = 100

var direction: Vector2 = Vector2(0, 0)
var speed: float

func _init():
	speed = base_speed

func _physics_process(delta):
	position += direction * speed * delta
	
func set_direction(dir: Vector2):
	direction = dir
	rotation = direction.angle() + PI / 2.0

func set_speed(spd: float):
	speed = spd

func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()

func _on_area_entered(area):
	if area.is_in_group("player") and not area.is_dead:
		area.damage(1)
		queue_free()
