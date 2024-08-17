extends Area2D

@export var speed: float = 500
@export var focus_factor: float = 0.5
@export var rotation_speed: float = 1

@onready var sprite = $Sprite2D

var vel := Vector2(0, 0)
var cur_speed := speed
var previous_mouse_position

func _process(delta):
	pass

func _physics_process(delta):
	# Update position
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
	
	# Update look at
	
	var gamepad_input = Input.get_vector("look_down", "look_up", "look_left", "look_right")
	var mouse_position = get_global_mouse_position()
	
	if gamepad_input.length() > 0.0:
		sprite.rotation = gamepad_input.angle()
	elif previous_mouse_position != mouse_position:
		sprite.look_at(mouse_position)
		sprite.rotate(PI / 2.0)
	
	previous_mouse_position = mouse_position
	
