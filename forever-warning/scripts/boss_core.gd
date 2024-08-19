extends Area2D

class_name BossCore

@export var base_life: int = 5
@export var speed: float = 50.0
@export var shoot_frequency: float = 10.0
@export var base_chance_to_fire: float = 0.5
@export var boss_spawn_delay := 0.5
@export var move_frequency_min := 2.0
@export var move_frequency_max := 2.0

@onready var shoot_timer = $ShootTimer
@onready var parts_side_slots = [$BossPartSlots/BossPartSlot1_L, $BossPartSlots/BossPartSlot1_R]
@onready var parts_down_slots = [$BossPartSlots/BossPartSlot2_L, $BossPartSlots/BossPartSlot2_R]
@onready var parts_up_slots = [$BossPartSlots/BossPartSlot3_L, $BossPartSlots/BossPartSlot3_R]
@onready var left_weapon_slots = $BossWeaponSlots/Left
@onready var right_weapon_slots = $BossWeaponSlots/Right
@onready var boss_spawn = $"../BossSpawn"
@onready var sprite: Sprite2D = $Sprite2D
@onready var animation: AnimationPlayer = $AnimationPlayer
@onready var move_timer: Timer = $MoveTimer

signal died_signal

var life: int
var total_life: int
var chance_to_fire: float
var is_dead = true # dead by default
var is_dying = false
var is_spawning = false
var is_invincible = false
var core_parts_instances = []
var parts_instances = []
var weapon_instances = []
var target_position: Vector2
var move_tween: Tween

func _ready():
	life = base_life;
	chance_to_fire = base_chance_to_fire
	setup(0)

func _process(delta):
	if is_dead or is_dying or game.player.is_dead or game.is_paused or is_spawning:
		return
		 
	if shoot_timer.is_stopped():
		shoot_timer.start(shoot_frequency)
		var rand = game.rng().randf()
		if rand <= chance_to_fire:
			shoot()
	
	if move_timer.is_stopped() and ((move_tween != null and not move_tween.is_running()) or move_tween == null):
		#target_position = get_random_position_around(100.0)
		print("MOVE RANDOMLY")
		move_randomly()
	
	#position = lerp(position, target_position, 0.5 * delta)
	
	# TODO: Handle rotation here
	#rotate(0.5 * delta)

func get_random_position_around(range: float):
	return global_position + _random_inside_unit_circle() * range

func move_randomly():
	var random_position = get_random_position_around(game.rng().randi_range(50, 1000.0))
	var random_rotation = game.rng().randf_range(0.0, PI)
	if move_tween != null:
		move_tween.kill()
	var tween_duration = global_position.distance_to(random_position) / speed
	move_tween = create_tween()
	move_tween.tween_property(self, "position", random_position, tween_duration).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	move_tween.parallel().tween_property(self, "rotation", random_rotation, tween_duration).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	move_tween.tween_callback(func(): move_timer.start(game.rng().randf_range(move_frequency_min, move_frequency_max)))

func _random_inside_unit_circle() -> Vector2:
	var theta : float = game.rng().randf() * 2 * PI
	return Vector2(cos(theta), sin(theta)) * sqrt(game.rng().randf())

func damage(amount: int, is_direct_hit: bool = true):
	if is_invincible:
		return
		
	if is_direct_hit:
		animation.play("hit")
		
	life -= amount
	game.hud.set_boss_life(life)
	if life <= 0 and not is_dead:
		kill()

func kill():
	if is_dead or is_dying:
		return
	
	is_dying = true
	sprite.visible = false
	
	for weapon in weapon_instances:
		if weapon.is_visible():
			weapon.kill()
	
	game.spawn_explosion(global_position)
	
	# to delay destruction
	var timer := get_tree().create_timer(game.rng().randf_range(0.3, 0.3))
	await timer.timeout
	
	for part in core_parts_instances:
		part.kill()
		part.died_signal.connect(_on_part_died)
	
	if are_all_parts_dead():
		true_kill()
	move_tween.kill()

func _on_part_died():
	if not are_all_parts_dead():
		return
	true_kill()

func are_all_parts_dead():
	for part in core_parts_instances:
		if not part.is_dead:
			return false
	return true

func true_kill():
	is_dying = false
	is_dead = true
	for part in parts_instances:
		if part[0].died_signal.is_connected(_on_part_died):
			part[0].died_signal.disconnect(_on_part_died)
		if part[1].died_signal.is_connected(_on_part_died):
			part[1].died_signal.disconnect(_on_part_died)
		
	died_signal.emit()	

func shoot():
	# TODO: Have multiple possible attacks
	if game.rng().randf() < 0.9:
		shoot_bullets_in_circle(10)
	else:
		shoot_multiple_bullets_in_circle(game.rng().randi_range(5, 20))

#region Generation

func setup(parts_count: int = 1, show_warnings: bool = true):
	#return
	
	# Wait a small amount of time before to respawn the boss
	var timer := get_tree().create_timer(boss_spawn_delay)
	await timer.timeout
	
	show_warnings = false
	
	if show_warnings:
		game.hud.show_warning_animation()	
		
		# Wait for the warning animation
		var warning_animation_timer := get_tree().create_timer(4.5)
		await warning_animation_timer.timeout
	
	global_position = boss_spawn.global_position
	global_rotation = boss_spawn.global_rotation
	
	if game.wave_count == 1:
		spawn_core_weapons()
	else:
		# reset all boss parts
		for part in parts_instances:
			part[0].setup()
			part[1].setup()
	
	for i in range(0, parts_count):
		spawn_new_parts()

	for weapon in weapon_instances:
		weapon.setup()
	
	sprite.visible = true
	is_dead = false
	is_dying = false
		
	compute_life()
	life = total_life
	refresh_hud_boss_life()
	
	is_spawning = true
	is_invincible = true
	
	visible = true
	scale = Vector2.ZERO
	
	var spawn_time = 1
	var tween = create_tween()
	tween.parallel().tween_property(self, "scale", Vector2.ONE, spawn_time).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	
	# wait for the spawn animation
	var spawn_timer := get_tree().create_timer(spawn_time)
	await spawn_timer.timeout
	
	target_position = position
	is_spawning = false
	is_invincible = false

# boss core life depends of all its members
func compute_life():
	total_life = base_life
	
	for instance in parts_instances:
		total_life += instance[0].base_life
		total_life += instance[1].base_life
	
func refresh_hud_boss_life():
	game.hud.set_boss_life(life)

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
	var random_slot_left_parent = random_slot[0].get_related_part()
	if random_slot_left_parent != null:
		random_slot_left_parent.add_sub_part(boss_part_left)
	# right
	random_slot[1].affect_part(boss_part_right)
	var random_slot_right_parent = random_slot[1].get_related_part()
	if random_slot_right_parent != null:
		random_slot_right_parent.add_sub_part(boss_part_right)
	
	# apply a random rotation on the new part
	var random_rotation = game.rng().randf_range(random_slot[0].base_random_angle_min, random_slot[0].base_random_angle_max)
	var random_rotation_speed = game.rng().randf_range(0.01, 0.05)
	# TODO: should depends on the slot instead
	var random_angle_amplitude = game.rng().randf_range(0.0, random_slot[0].angle_amplitude)
	boss_part_left.set_base_angle(random_rotation)
	boss_part_right.set_base_angle(random_rotation)
	boss_part_left.set_rotation_speed(random_rotation_speed)
	boss_part_right.set_rotation_speed(random_rotation_speed)
	boss_part_left.set_angle_amplitude(random_angle_amplitude)
	boss_part_right.set_angle_amplitude(random_angle_amplitude)

	boss_part_left.setup()
	boss_part_right.setup()

	spawn_new_weapons(boss_part_left, boss_part_right)

	if random_slot[0].get_related_part() == null:
		core_parts_instances.append(boss_part_left)
	if random_slot[1].get_related_part() == null:
		core_parts_instances.append(boss_part_right)

	parts_instances.append([boss_part_left, boss_part_right])

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
	for part in parts_instances:
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
	var max_weapon = 2
	var weapon_count = 0
	for i in left_children.size():
		if left_children[i].is_visible() and game.rng().randf() > 0.75:
			weapon_count += 1
			var random_weapon = game.get_random_boss_weapon()
			var left_weapon = random_weapon.instantiate()
			var right_weapon = random_weapon.instantiate()
			left_children[i].affect_weapon(left_weapon)
			right_children[i].affect_weapon(right_weapon)
			weapon_instances.append(left_weapon)
			weapon_instances.append(right_weapon)
			
			if weapon_count >= max_weapon:
				break

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
				left_part.add_weapon(left_weapon)
				right_part.add_weapon(right_weapon)

#endregion

#region Attacks

func shoot_one_bullet_toward_player():
	# Shoot bullet toward player
	if game.player != null:
		var direction = (game.player.global_position - global_position).normalized()
		game.instantiate_bullet(global_position, direction, 100, 1)
	pass

func shoot_bullets_in_circle(count: int):
	var spd = game.rng().randi_range(100, 500)
	var base_angle = game.rng().randfn() * 360.0
	for i:float in count:
		var angle = base_angle + ((i / count) * 360) * (PI/180.0)
		var direction = Vector2(sin(angle), cos(angle))
		game.instantiate_bullet(global_position, direction, spd, 1)

func shoot_multiple_bullets_in_circle(count: int):
	var spd = game.rng().randi_range(100, 500)
	var base_angle = game.rng().randfn() * 360.0
	for i in range(game.rng().randi_range(3, 15)):
		base_angle += PI / 3.0 # offset
		for j:float in count:
			var angle = base_angle + ((j / count) * 360) * (PI/180.0)
			var direction = Vector2(sin(angle), cos(angle))
			game.instantiate_bullet(global_position, direction, spd, 1)
		# Wait between each bullets circle
		var timer := get_tree().create_timer(0.1)
		await timer.timeout
#endregion

func _on_area_entered(area):
	if is_dead:
		return
	# kill player on contact
	if area.is_in_group("player") and not area.is_dead:
		area.damage(1)
