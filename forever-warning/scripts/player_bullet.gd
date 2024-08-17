extends Area2D

@export var speed: float = 800

var direction: Vector2 = Vector2(0, 0)

func _physics_process(delta):
	position += direction * speed * delta
	
func set_direction(dir: Vector2):
	direction = dir
	rotation = direction.angle() + PI / 2.0

func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()

func _on_area_entered(area):
	if area.is_in_group("damageable"):
		if not area.is_dead:
			area.damage(1)
			queue_free()
