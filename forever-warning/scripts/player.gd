extends Area2D

@export var speed: float = 500
@export var focus_factor: float = 0.5
@export var rotation_speed: float = 1
@export var fire_delay: float = 0.1

@onready var fire_delay_timer = $FireDelayTimer
@onready var bullet_spawners = $BulletSpawners
@onready var player_spawn = $"../PlayerSpawn"

signal died_signal

var bullet_node := preload("res://scenes/bullets/player_bullet.tscn")
var vel := Vector2(0, 0)
var cur_speed
var previous_mouse_position
var is_using_gamepad = true

func _ready():
	game.set_player(self)

func _process(_delta):
	# Shoot
	if Input.is_action_pressed("shoot") and fire_delay_timer.is_stopped():
		is_using_gamepad = false
		fire_delay_timer.start(fire_delay)
		for child in bullet_spawners.get_children():
			if child.is_visible():
				var bullet = bullet_node.instantiate()
				bullet.global_position = child.global_position
				bullet.set_direction(Vector2.from_angle(rotation - PI / 2.0))
				get_tree().current_scene.add_child(bullet)

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
		is_using_gamepad = true
		rotation = gamepad_input.angle()
	elif not is_using_gamepad:
		look_at(mouse_position)
		rotate(PI / 2.0)
	
	previous_mouse_position = mouse_position
	
func damage(amount: int):
	died_signal.emit()

func set_invincibility(time: float):
	# TODO: Implement this
	pass

func respawn():
	global_position = player_spawn.global_position
	global_rotation = player_spawn.global_rotation
	set_invincibility(3.0)
