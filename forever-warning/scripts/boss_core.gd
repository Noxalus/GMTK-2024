extends Area2D

@export var life: int = 20
@export var speed: float = 300
@export var shoot_frequency: float = 1.0
@export var base_chance_to_fire: float = 0.5
@export var boss_spawn_delay := 0.5

@onready var player = $"../Player"
@onready var shoot_timer = $ShootTimer
@onready var parts_side_slots = [$BossPartSlots/BossPartSlot1_L, $BossPartSlots/BossPartSlot1_R]
@onready var parts_down_slots = [$BossPartSlots/BossPartSlot2_L, $BossPartSlots/BossPartSlot2_R]
@onready var parts_up_slots = [$BossPartSlots/BossPartSlot3_L, $BossPartSlots/BossPartSlot3_R]

signal died_signal

var bullet_node := preload("res://scenes/boss_bullet.tscn")
var rng = RandomNumberGenerator.new()
var chance_to_fire: float
var is_dead = true # dead by default
var boss_parts = []

func _ready():
	chance_to_fire = base_chance_to_fire
	setup()
	
func _process(_delta):
	if is_dead:
		return
		 
	if shoot_timer.is_stopped():
		shoot_timer.start(shoot_frequency)
		var rand = rng.randf()
		if rand > chance_to_fire:
			shoot()

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
	if rng.randf() > 0.5:
		shoot_one_bullet_toward_player()
	else:
		shoot_bullets_in_circle(10)

func instantiate_bullet(dir: Vector2):
	var bullet = bullet_node.instantiate()
	bullet.global_position = global_position
	bullet.set_direction(dir)
	get_tree().current_scene.add_child(bullet)

#region Generation

func setup():
	# Wait a small amount of time before to respawn the boss
	var timer := get_tree().create_timer(boss_spawn_delay)
	await timer.timeout
	life = 20
	visible = true
	is_dead = false
	spawn_new_parts()
	spawn_new_weapons()

func spawn_new_parts():
	var unoccupied_slots = find_unoccupied_slots()
	
	if unoccupied_slots.size() == 0:
		return
	
	var random_slot = unoccupied_slots[rng.randi_range(0, unoccupied_slots.size() - 1)]
	
	var random_boss_part = game.get_random_boss_part()
	var boss_part_right = random_boss_part.instantiate()
	var boss_part_left = random_boss_part.instantiate()
	boss_part_left.flip()
	
	# left
	random_slot[0].affect_part(boss_part_left)
	# right
	random_slot[1].affect_part(boss_part_right)
	
	# apply a random rotation on the new part
	var random_rotation = rng.randf_range(0.0, PI)
	var random_rotation_speed = rng.randf_range(0.1, 0.5)
	# TODO: should depends on the slot instead
	var random_angle_amplitude = rng.randf_range(0.0, boss_part_right.angle_amplitude)
	boss_part_left.set_base_angle(random_rotation)
	boss_part_right.set_base_angle(-random_rotation)
	boss_part_left.set_rotation_speed(random_rotation_speed)
	boss_part_right.set_rotation_speed(random_rotation_speed)
	boss_part_left.set_angle_amplitude(random_angle_amplitude)
	boss_part_right.set_angle_amplitude(random_angle_amplitude)

	boss_parts.append([boss_part_left, boss_part_right])

func find_unoccupied_slots():
	var unoccupied_slots = []
	# Find unocuppied boss part slots in the core first
	if not parts_side_slots[0].is_occupied:
		unoccupied_slots.append([parts_side_slots[0], parts_side_slots[1]])
	if not parts_up_slots[0].is_occupied:
		unoccupied_slots.append([parts_up_slots[0], parts_up_slots[1]])
	if not parts_down_slots[0].is_occupied:
		unoccupied_slots.append([parts_down_slots[0], parts_down_slots[1]])
		
	# TODO: Look on all boss parts
		
	return unoccupied_slots
	
func spawn_new_weapons():
	pass

#endregion

#region Attacks

func shoot_one_bullet_toward_player():
	# Shoot bullet toward player
	if player != null:
		var direction = (player.global_position - global_position).normalized()
		instantiate_bullet(direction)
	pass

func shoot_bullets_in_circle(count: int):
	for i:float in count:
		var angle = ((i / count) * 360) * (PI/180.0)
		var direction = Vector2(sin(angle), cos(angle))
		instantiate_bullet(direction)
		
#endregion
