extends CharacterBody3D
class_name Player

@export var speed = 5.0
@export var acceleration = 4.0
@export var jump_speed = 8.0
@export var rotation_speed = 12.0
@export var camera_rotation_speed = 8.0
@export var mouse_sensitivity = 0.0015

@onready var spring_arm = $SpringArm3D
@onready var model = $Skeleton3D
@onready var anim_tree = $AnimationTree
@onready var anim_state = $AnimationTree.get("parameters/playback")

var jumping = false
var last_floor = false

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	get_move_input(delta)
	move_and_slide()

	if (velocity.length() > 1.0):
		model.rotation.y = lerp_angle(model.rotation.y, spring_arm.rotation.y + 135, rotation_speed * delta)

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_speed
		jumping = true
		anim_tree.set("parameters/conditions/jumping", true)
		anim_tree.set("parameters/conditions/grounded", false)
	if is_on_floor() and not last_floor:
		jumping = false
		anim_tree.set("parameters/conditions/jumping", false)
		anim_tree.set("parameters/conditions/grounded", true)
	if not is_on_floor() and not jumping:
		anim_state.travel("Jump_Idle")
		anim_tree.set("parameters/conditions/grounded", false)

	last_floor = is_on_floor()

func get_move_input(delta):
	var vy = velocity.y
	velocity.y = 0
	var input = Input.get_vector("left", "right", "forward", "back")
	var dir = Vector3(input.x, 0, input.y).rotated(Vector3.UP, spring_arm.rotation.y)
	var vl = velocity * model.transform.basis
	anim_tree.set("parameters/IdleWalkRun/blend_position", Vector2(-vl.x, vl.z) / speed)
	velocity = lerp(velocity, dir * speed, acceleration * delta)
	velocity.y = vy
	
	# Move camera with the gamepad
	var gamepad_input = Input.get_vector("look_left", "look_right", "look_up", "look_down")
	spring_arm.rotation.x -= gamepad_input.y * camera_rotation_speed * delta
	spring_arm.rotation_degrees.x = clamp(spring_arm.rotation_degrees.x, -90.0, 30.0)
	spring_arm.rotation.y -= gamepad_input.x * camera_rotation_speed * delta

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		spring_arm.rotation.x -= event.relative.y * mouse_sensitivity
		spring_arm.rotation_degrees.x = clamp(spring_arm.rotation_degrees.x, -90.0, 30.0)
		spring_arm.rotation.y -= event.relative.x * mouse_sensitivity
	if event.is_action_pressed("attack"):
		anim_state.travel("NoWeaponAttack")
