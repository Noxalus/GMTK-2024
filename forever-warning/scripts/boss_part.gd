extends Area2D

class_name BossPart

@export var base_rotation_speed: float = 5.0
@export var base_life: int = 10

@onready var boss_parts_slots = $BossPartSlots
@onready var boss_weapons_slots = $BossWeaponSlots
@onready var animation = $AnimationPlayer
@onready var sprite: Sprite2D = $Sprite

signal died_signal

var life
var is_dead := true # dead by default
var is_dying := false
var base_angle := 0.0
var base_min_angle := 0.0
var base_max_angle := 0.0
var min_angle := 0.0
var max_angle := 0.0
var rotation_speed := 0.0
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
	is_dying = false
	sprite.visible = true
	for weapon in weapons:
		weapon.setup()

func add_weapon(weapon):
	weapons.append(weapon)

func add_sub_part(part):
	subparts.append(part)

func _physics_process(delta):
	if is_dead or is_dying or game.player.is_dead or game.is_paused or game.boss.is_spawning:
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
	if game.boss.is_invincible:
		return
	
	life -= amount
	game.boss.damage(amount, false)
	animation.play("hit")
	if life < 0:
		kill()

func kill():
	if is_dying or is_dead:
		return
	
	is_dying = true
	sprite.visible = false
	
	for weapon in weapons:
		if weapon.is_visible(): 
			weapon.kill()

	game.boss.damage(life)
	game.spawn_explosion(global_position)

	# to delay destruction
	var timer := get_tree().create_timer(game.rng().randf_range(0.1, 0.1))
	await timer.timeout

	#var explosion = game.spawn_explosion(global_position)
	#await explosion.tree_exited
	
	for part in subparts:
		if not part.is_dead:
			part.kill()
			part.died_signal.connect(_on_subpart_died)
	
	var are_all_subparts_destroyed = true
	for part in subparts:
		if not part.is_dead:
			are_all_subparts_destroyed = false
			break
	
	if are_all_subparts_destroyed:
		true_kill()

func _on_subpart_died():
	for part in subparts:
		if not part.is_dead:
			return
	true_kill()

func true_kill():
	is_dying = false
	is_dead = true
	for part in subparts:
		if part.died_signal.is_connected(_on_subpart_died):
			part.died_signal.disconnect(_on_subpart_died)
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

func _on_area_entered(area):
	if is_dead:
		return
	# kill player on contact
	if area.is_in_group("player") and not area.is_dead:
		area.damage(1)
