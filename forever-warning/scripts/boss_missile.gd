extends Area2D

var direction: Vector2 = Vector2.ONE
var speed: float = 500
var rotation_speed: float = 0.01
var homing_time := 1.0
var idle_time := 0.25
var is_dead := false
var target_direction := Vector2.ZERO

@onready var alive_timer: Timer = $AliveTimer
@onready var homing_timer: Timer = $HomingTimer
@onready var idle_timer: Timer = $IdleTimer

func _ready() -> void:
	homing_timer.start(homing_time)

func _process(delta: float) -> void:
	if game.is_paused or game.player == null or game.boss == null:
		return

	if game.player.is_dead:# or game.boss.is_dead:
		kill()
	
	# CHASING THE PLAYER
	if not homing_timer.is_stopped():
		target_direction = game.player.position - global_position
		direction = lerp(direction, target_direction, rotation_speed * delta)
		direction = direction.normalized()
			
	position += direction * speed * delta
	rotation = direction.angle() + PI / 2.0
	
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

func _on_idle_timer_timeout() -> void:
	homing_timer.start(homing_time)

func _on_homing_timer_timeout() -> void:
	idle_timer.start(idle_time)
