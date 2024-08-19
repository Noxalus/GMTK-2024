extends Node2D

# Assets preloading
var boss_core = preload("res://scenes/boss_core.tscn")
var boss_parts = [
	preload("res://scenes/boss_parts/boss_part_1.tscn"),
	preload("res://scenes/boss_parts/boss_part_2.tscn"),
	preload("res://scenes/boss_parts/boss_part_3.tscn"),
	preload("res://scenes/boss_parts/boss_part_4.tscn"),
	preload("res://scenes/boss_parts/boss_part_5.tscn"),
	preload("res://scenes/boss_parts/boss_part_6.tscn"),
]
var boss_weapons = [
	preload("res://scenes/boss_weapons/boss_weapon_turret.tscn")
]

var bullet_nodes := [
	preload("res://scenes/bullets/boss_bullet_1.tscn"),
	preload("res://scenes/bullets/boss_bullet_2.tscn")
]

var explosion := preload("res://scenes/fx/explosion.tscn")
var player_explosion := preload("res://scenes/fx/player_explosion.tscn")

const upgrade_class = preload("res://scripts/upgrade.gd")

var upgrades = [
	# LIFE + 1
	upgrade_class.new(
		preload("res://assets/sprites/upgrades/increase_lives.png"), 
		"LIFE + 1", 
		increase_player_life,
		func(): return true
	),
	# SHOOT FREQUENCY x1.5
	upgrade_class.new(
		preload("res://assets/sprites/upgrades/increase_shoot_frequency.png"), 
		"SHOOT FREQUENCY x1.5", 
		func(): 	player.increase_shoot_frequency(),
		func(): return true
	),
	# DAMAGE INCREASE x1.25
	upgrade_class.new(
		preload("res://assets/sprites/upgrades/increase_damage.png"), 
		"DAMAGE INCREASE x2", 
		func(): 	player.increase_damage(),
		func(): return true
	),
	# TURRET + 1
	upgrade_class.new(
		preload("res://assets/sprites/upgrades/increase_turret.png"), 
		"TURRET + 1", 
		func(): 	player.add_turret(),
		func(): return player.can_add_turret()
	),
	# CORE DAMAGE x1.5
	upgrade_class.new(
		preload("res://assets/sprites/upgrades/increase_core_damage.png"), 
		"CORE DAMAGE x2", 
		increase_core_damage,
		func(): return true
	),
	# MOVE SPEED x1.25
	upgrade_class.new(
		preload("res://assets/sprites/upgrades/increase_move_speed.png"), 
		"MOVE SPEED x1.25", 
		func(): 	player.increase_move_speed(),
		func(): return true
	),
]

func increase_player_life():
	print("PLAYER LIVES BEFORE UPDATE %s" % player_lives)
	player_lives += 1
	print("PLAYER LIVE AFTER UPDATE %s" % player_lives)
	hud.refresh_player_lives()

func increase_core_damage():
	print("CORE DAMAGE BEFORE UPDATE %s" % core_damage_factor)
	core_damage_factor *= 2
	print("CORE DAMAGE AFTER UPDATE %s" % core_damage_factor)

var local_rng = RandomNumberGenerator.new()

const base_player_lives := 3
const base_core_damage_factor := 1.0

var player_lives = base_player_lives
var camera = null
var boss = null
var player = null
var hud = null
var wave_count: int = 0
var bullets = []
var is_paused = false
var core_damage_factor: float

func _ready():
	reset()
	spawn_new_boss()

func _process(delta):
	# debug to test boss generation quickly
	if Input.is_action_just_pressed("next_boss") and boss != null:
		spawn_new_boss()
	if Input.is_action_just_pressed("kill_boss") and boss != null:
		boss.damage(999999)
	if Input.is_action_just_pressed("restart") and boss != null:
		restart()
	if Input.is_action_just_pressed("choose_upgrade"):
		hud.show_upgrades()

func reset() -> void:
	# reset gameplay values
	wave_count = 0
	player_lives = base_player_lives
	core_damage_factor = base_core_damage_factor
	is_paused = false

func restart():
	reset()
	
	# reset main entities
	player.reset()
	hud.reset()
	
	# respawn entities
	boss.queue_free()
	boss = null
	spawn_new_boss()
	player.respawn()

func clear_boss_bullets():
		# clean all existing bullets
	for bullet in bullets:
		if bullet != null:
			bullet.queue_free()
	bullets.clear()
	
func spawn_new_boss():
	clear_boss_bullets()
	wave_count += 1
	
	if hud != null: 
		hud.set_wave_count(wave_count)
	
	if boss == null:
		boss = boss_core.instantiate()
		boss.visible = false
		get_tree().current_scene.add_child(boss)
		boss.died_signal.connect(_on_boss_death)
	else:
		boss.setup(1)
		
func _on_boss_death():
	if player.is_dead and player_lives <= 0:
		return
		
	if can_show_upgrades():
		hud.show_upgrades()
	else:
		spawn_new_boss()

func get_random_boss_part():
	return boss_parts[rng().randi_range(0, boss_parts.size() - 1)]
	
func get_random_boss_weapon():
	return boss_weapons[rng().randi_range(0, boss_weapons.size() - 1)]
	
func instantiate_bullet(pos: Vector2, dir: Vector2, speed: float = 100, bullet_index: int = 0):
	var bullet = bullet_nodes[bullet_index].instantiate()
	bullet.global_position = pos
	bullet.set_direction(dir)
	bullet.set_speed(speed)
	get_tree().current_scene.add_child(bullet)
	bullets.append(bullet)
	
func rng():
	return local_rng
	
func spawn_explosion(pos: Vector2):
	var instance = explosion.instantiate()
	instance.position = pos
	instance.emitting = true
	get_tree().current_scene.add_child(instance)
	game.camera.shake(7.5)
	return instance

func set_player(p):
	player = p
	player.died_signal.connect(_on_player_died)

func _on_player_died():
	# player explosion
	var instance = player_explosion.instantiate()
	instance.global_position = player.global_position
	instance.global_rotation = player.global_rotation
	instance.emitting = true
	get_tree().current_scene.add_child(instance)
	
	player_lives -= 1
	hud.set_lives(player_lives)
	
	if (player_lives <= 0):
		hud.show_game_over()
		player.kill()
	else:
		var timer := get_tree().create_timer(1.5)
		await timer.timeout
		player.respawn()

func can_show_upgrades():
	# should we limit this every X wave?
	# easy to do with a module on the wave_count
	return wave_count % 5 == 0

func pause():
	is_paused = true

func unpause():
	is_paused = false

func active_bonus(up: Upgrade):
	# active the bonus
	up.execute_effect()
	hud.hide_upgrades()
	spawn_new_boss()

func get_random_upgrades(count: int):
	var available_upgrades = upgrades.duplicate()

	# remove unavailable upgrades
	var index_to_remove = []
	for i in available_upgrades.size():
		if not available_upgrades[i].check_is_available():
			index_to_remove.append(i)

	for i in index_to_remove:
		available_upgrades.remove_at(i)
	
	var random_upgrades = []
	
	for i in count:
		var random_index = rng().randi_range(0, available_upgrades.size() - 1)
		random_upgrades.append(available_upgrades[random_index])
		available_upgrades.remove_at(random_index)
	
	return random_upgrades
