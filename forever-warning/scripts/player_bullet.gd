extends Area2D

@export var speed: float = 800

var bullet_fx := preload("res://scenes/fx/bullet_fx.tscn")

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
			var instance = bullet_fx.instantiate()
			instance.global_position = global_position
			instance.global_rotation = global_rotation
			instance.emitting = true
			get_tree().current_scene.add_child(instance)
			area.damage(1)
			game.player.play_hit_sound()
			queue_free()
