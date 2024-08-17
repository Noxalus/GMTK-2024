extends Area2D

var speed: float = 1000
var vel := Vector2(0, 0)

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

	vel = dirVel.normalized() * speed;
	position += vel * delta;
