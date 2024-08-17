extends Area2D

@export var base_life: int = 5
@export var speed: float = 300
@export var shoot_frequency: float = 1.0
@export var base_chance_to_fire: float = 0.5
@export var boss_spawn_delay := 0.5

@onready var shoot_timer = $ShootTimer
@onready var parts_side_slots = [$BossPartSlots/BossPartSlot1_L, $BossPartSlots/BossPartSlot1_R]
@onready var parts_down_slots = [$BossPartSlots/BossPartSlot2_L, $BossPartSlots/BossPartSlot2_R]
@onready var parts_up_slots = [$BossPartSlots/BossPartSlot3_L, $BossPartSlots/BossPartSlot3_R]
@onready var left_weapon_slots = $BossWeaponSlots/Left
@onready var right_weapon_slots = $BossWeaponSlots/Right

signal died_signal

var life
var chance_to_fire: float
var is_dead = true # dead by default
var instanciated_boss_parts = []

func _ready():
	life = base_life;
	chance_to_fire = base_chance_to_fire
	setup()
	
func _process(delta):
	if is_dead:
		return
		 
	if shoot_timer.is_stopped():
		shoot_timer.start(shoot_frequency)
		var rand = game.rng().randf()
		if rand <= chance_to_fire:
			shoot()
			
	# TODO: Handle rotation here
	#rotate(0.5 * delta)

func damage(amount: int):
	life -= amount
	if life < 0:
		visible = false
		is_dead = true
		died_signal.emit()

func is_alive():
	return not is_dead

func shoot():
	# TODO: Have multiple possible attacks
	if game.rng().randf() > 0.5:
		shoot_one_bullet_toward_player()
	else:
		shoot_bullets_in_circle(10)

#region Generation

func setup():
	# Wait a small amount of time before to respawn the boss
	var timer := get_tree().create_timer(boss_spawn_delay)
	await timer.timeout
	life = base_life
	visible = true
	is_dead = false
	
	if instanciated_boss_parts.size() == 0:
		spawn_core_weapons()
	else:
		# reset all boss parts
		for part in instanciated_boss_parts:
			part[0].setup()
			part[1].setup()
		
	spawn_new_parts()

func spawn_new_parts():
	var unoccupied_slots = find_unoccupied_slots()
	
	if unoccupied_slots.size() == 0:
		return
	
	var random_slot = unoccupied_slots[game.rng().randi_range(0, unoccupied_slots.size() - 1)]
	
	var random_boss_part = game.get_random_boss_part()
	var boss_part_right = random_boss_part.instantiate()
	var boss_part_left = random_boss_part.instantiate()
	
	# left
	random_slot[0].affect_part(boss_part_left)
	# right
	random_slot[1].affect_part(boss_part_right)
	
	# apply a random rotation on the new part
	var random_rotation = game.rng().randf_range(-random_slot[0].angle_amplitude, random_slot[0].angle_amplitude)
	var random_rotation_speed = game.rng().randf_range(0.01, 0.05)
	# TODO: should depends on the slot instead
	var random_angle_amplitude = game.rng().randf_range(0.0, random_slot[0].angle_amplitude)
	boss_part_left.set_base_angle(-random_rotation)
	boss_part_right.set_base_angle(-random_rotation)
	boss_part_left.set_rotation_speed(random_rotation_speed)
	boss_part_right.set_rotation_speed(random_rotation_speed)
	boss_part_left.set_angle_amplitude(random_angle_amplitude)
	boss_part_right.set_angle_amplitude(random_angle_amplitude)

	boss_part_left.setup()
	boss_part_right.setup()

	spawn_new_weapons(boss_part_left, boss_part_right)

	instanciated_boss_parts.append([boss_part_left, boss_part_right])

func find_unoccupied_slots():
	var unoccupied_slots = []
	# Find unocuppied boss part slots in the core first
	if parts_side_slots[0].is_visible() and not parts_side_slots[0].is_occupied:
		unoccupied_slots.append([parts_side_slots[0], parts_side_slots[1]])
	if parts_up_slots[0].is_visible() and not parts_up_slots[0].is_occupied:
		unoccupied_slots.append([parts_up_slots[0], parts_up_slots[1]])
	if parts_down_slots[0].is_visible() and not parts_down_slots[0].is_occupied:
		unoccupied_slots.append([parts_down_slots[0], parts_down_slots[1]])
	
	# Find unoccupied boss part slots on the already instanciated boss parts
	for part in instanciated_boss_parts:
		var left_slots = part[0].find_unoccupied_part_slots()
		if left_slots.size() > 0:
			# Get the same slots for the right part
			var right_slots = part[1].find_unoccupied_part_slots()
			for i in left_slots.size():
				unoccupied_slots.append([left_slots[i], right_slots[i]])
				
	return unoccupied_slots

func spawn_core_weapons():
	var left_children = left_weapon_slots.get_children()
	var right_children = right_weapon_slots.get_children()
	for i in left_children.size():
		if left_children[i].is_visible() and game.rng().randf() > 0.5:
			var random_weapon = game.get_random_boss_weapon()
			var left_weapon = random_weapon.instantiate()
			var right_weapon = random_weapon.instantiate()
			left_children[i].affect_weapon(left_weapon)
			right_children[i].affect_weapon(right_weapon)

func spawn_new_weapons(left_part, right_part):
	var unoccupied_slots = []
	var left_slots = left_part.find_unoccupied_weapon_slots()
	if left_slots.size() > 0:
		# Get the same slots for the right part
		var right_slots = right_part.find_unoccupied_weapon_slots()
		for i in left_slots.size():
			# Chance to spawn a weapon
			if (game.rng().randf() > 0.5):
				var random_weapon = game.get_random_boss_weapon()
				var left_weapon = random_weapon.instantiate()
				var right_weapon = random_weapon.instantiate()
				left_slots[i].affect_weapon(left_weapon)
				right_slots[i].affect_weapon(right_weapon)

#endregion

#region Attacks

func shoot_one_bullet_toward_player():
	# Shoot bullet toward player
	if game.player != null:
		var direction = (game.player.global_position - global_position).normalized()
		game.instantiate_bullet(global_position, direction)
	pass

func shoot_bullets_in_circle(count: int):
	for i:float in count:
		var angle = ((i / count) * 360) * (PI/180.0)
		var direction = Vector2(sin(angle), cos(angle))
		game.instantiate_bullet(global_position, direction)
		
#endregion
