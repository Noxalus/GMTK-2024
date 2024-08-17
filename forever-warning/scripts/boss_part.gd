extends Area2D

@export var base_rotation_speed: float = 5.0

@onready var boss_parts_slots = $BossPartSlots

var rng = RandomNumberGenerator.new()
var base_angle = 0.0
var base_min_angle = 0.0
var base_max_angle = 0.0
var min_angle = 0.0
var max_angle = 0.0
var rotation_speed = 0.0
var is_rotating_clockwise;

func _ready():
	rotation_speed = base_rotation_speed

func is_flipped():
	return scale.x == -1

func flip():
	scale.x = -1

func _physics_process(delta):
	
	if base_min_angle < 0.0 and base_max_angle > 0.0:
		var flip_factor = 1
		
		if is_flipped():
			flip_factor = -1
		
		var clockwise_factor = 1
		
		if is_rotating_clockwise and rotation >= max_angle:
			is_rotating_clockwise = false
		elif not is_rotating_clockwise and rotation <= min_angle:
			is_rotating_clockwise = true
		
		if not is_rotating_clockwise:
			clockwise_factor = -flip_factor
		else:
			clockwise_factor = flip_factor
		
		rotate(rotation_speed * flip_factor * clockwise_factor * delta)

func set_base_angle(angle: float):
	base_angle = angle
	rotation = base_angle

func set_angle_amplitude(amplitude: float):
	base_min_angle = -amplitude
	base_max_angle = amplitude
	
	min_angle = base_angle + base_min_angle
	max_angle = base_angle + base_max_angle
	
	if is_flipped():
		is_rotating_clockwise = false
	else:
		is_rotating_clockwise = true

func set_rotation_speed(speed: float):
	rotation_speed = 5

func find_unoccupied_slots():
	var parts = []
	if boss_parts_slots != null:
		for part in boss_parts_slots.get_children():
			if part.is_visible() and not part.is_occupied:
				parts.append(part)
	return parts
