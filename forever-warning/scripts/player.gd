extends Area2D

@export var speed: float = 500
@export var focus_factor: float = 0.5

var vel := Vector2(0, 0)
var cur_speed := speed

func _process(delta):
	pass

func _physics_process(delta):
	var dirVel := Vector2(0, 0)
	
	if Input.is_action_pressed("move_up"):
		dirVel.y = -1
	elif Input.is_action_pressed("move_down"):
		dirVel.y = 1

	if Input.is_action_pressed("move_left"):
		dirVel.x = -1
	elif Input.is_action_pressed("move_right"):
		dirVel.x = 1

	cur_speed = speed

	if Input.is_action_pressed("focus"):
		cur_speed = speed / 2.0

	vel = dirVel.normalized() * cur_speed;
	position += vel * delta;
