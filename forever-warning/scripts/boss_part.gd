extends Area2D

class_name BossPart

@export var base_rotation_speed: float = 5.0
@export var base_life: int = 10

@onready var boss_parts_slots = $BossPartSlots
@onready var boss_weapons_slots = $BossWeaponSlots

signal died_signal

var life
var is_dead = true # dead by default
var base_angle = 0.0
var base_min_angle = 0.0
var base_max_angle = 0.0
var min_angle = 0.0
var max_angle = 0.0
var rotation_speed = 0.0
var is_rotating_clockwise;
var weapons = []
var subparts = []

func _ready():
	rotation_speed = base_rotation_speed
	life = base_life

func is_flipped():
	return scale.x == -1

func flip():
	scale.x = -1

func setup():
	life = base_life
	rotation = base_angle
	is_dead = false
	visible = true
	for weapon in weapons:
		weapon.setup()

func add_weapon(weapon):
	weapons.append(weapon)

func add_sub_part(part):
	subparts.append(part)

func _physics_process(delta):
	if is_dead or game.player.is_dead:
		return
		
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

func damage(amount: int):
	life -= amount
	game.boss.damage(amount)
	if life < 0:
		kill()

func kill():
	game.boss.damage(life)
	visible = false
	is_dead = true
	for weapon in weapons:
		if weapon.is_visible(): 
			weapon.kill()
	for part in subparts:
		if part.is_visible():
			part.kill()
	game.spawn_explosion(global_position)
	died_signal.emit()

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
	rotation_speed = speed

func find_unoccupied_part_slots():
	var parts = []
	if boss_parts_slots != null:
		for part in boss_parts_slots.get_children():
			if part.is_visible() and not part.is_occupied:
				parts.append(part)
	return parts
	
func find_unoccupied_weapon_slots():
	var weapon_slots = []
	if boss_weapons_slots != null:
		for weapon_slot in boss_weapons_slots.get_children():
			if weapon_slot.is_visible() and not weapon_slot.is_occupied:
				weapon_slots.append(weapon_slot)
	return weapon_slots
