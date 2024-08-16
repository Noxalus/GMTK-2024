extends CharacterBody3D
class_name Player

@export var speed = 5.0
@export var acceleration = 4.0
@export var jump_speed = 8.0
@export var rotation_speed = 12.0
@export var mouse_sensitivity = 0.0015

@onready var spring_arm = $SpringArm3D
@onready var model = $Skeleton3D
@onready var anim_tree = $AnimationTree
@onready var anim_state = $AnimationTree.get("parameters/playback")

var gravity = get_gravity()
var jumping = false

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity += gravity * delta

	get_move_input(delta)
	move_and_slide()

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_speed

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	#var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	#var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	#if direction:
		#velocity.x = direction.x * speed
		#velocity.z = direction.z * speed
	#else:
		#velocity.x = move_toward(velocity.x, 0, speed)
		#velocity.z = move_toward(velocity.z, 0, speed)

func get_move_input(delta):
	var vy = velocity.y
	velocity.y = 0
	var input = Input.get_vector("left", "right", "forward", "back")
	var dir = Vector3(input.x, 0, input.y).rotated(Vector3.UP, spring_arm.rotation.y)
	velocity = lerp(velocity, dir * speed, acceleration * delta)
	velocity.y = vy

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		spring_arm.rotation.x -= event.relative.y * mouse_sensitivity
		spring_arm.rotation_degrees.x = clamp(spring_arm.rotation_degrees.x, -90.0, 30.0)
		spring_arm.rotation.y -= event.relative.x * mouse_sensitivity
