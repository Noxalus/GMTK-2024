extends Area2D

var direction: Vector2 = Vector2.ONE
var speed: float = 0.1
var is_dead := false

@onready var alive_timer: Timer = $AliveTimer

func _process(delta: float) -> void:
	if game.is_paused or game.player == null or game.player.is_dead:
		return
		
	# follow player
	direction = game.player.position - global_position
	rotation = direction.angle() + PI / 2.0
	position += direction * speed * delta
	
	if alive_timer.is_stopped():
		kill()

func damage(amount: int):
	kill()
	
func kill():
	if is_dead:
		return
	is_dead = true
	game.spawn_explosion(global_position)
	queue_free()

#func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	#queue_free()

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("player") and not area.is_dead:
		area.damage(1)
		queue_free()
