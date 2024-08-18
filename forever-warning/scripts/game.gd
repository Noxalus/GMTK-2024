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

var bullet_node := preload("res://scenes/bullets/boss_bullet.tscn")
var explosion := preload("res://scenes/fx/explosion.tscn")
var player_explosion := preload("res://scenes/fx/player_explosion.tscn")

const upgrade_class = preload("res://scripts/upgrade.gd")

var upgrades = [
	# LIFE + 1
	upgrade_class.new(
		preload("res://assets/sprites/boss_core_1.png"), 
		"LIFE + 1", 
		increase_player_life
	),
	# SHOOT FREQUENCY * 1.5
	upgrade_class.new(
		preload("res://assets/sprites/player_bullet.png"), 
		"SHOOT FREQUENCY x1.5", 
		func(): 	player.increase_shoot_frequency()
	),
]

func increase_player_life():
	player_lives += 1
	hud.refresh_player_lives()

var local_rng = RandomNumberGenerator.new()

const base_player_lives = 3
var player_lives = base_player_lives
var camera = null
var boss = null
var player = null
var hud = null
var wave_count: int = 0
var bullets = []
var is_paused = false

func _ready():
	spawn_new_boss()

func _process(delta):
	# debug to test boss generation quickly
	if Input.is_action_just_pressed("next_boss") and boss != null:
		spawn_new_boss()
	if Input.is_action_just_pressed("kill_boss") and boss != null:
		boss.damage(999999)
	if Input.is_action_just_pressed("restart") and boss != null:
		restart()

func restart():
	# reset gameplay values
	wave_count = 0
	player_lives = base_player_lives
	is_paused = false
	
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
		get_tree().current_scene.add_child(boss)
		boss.died_signal.connect(_on_boss_death)
	else:
		boss.setup()

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
	
func instantiate_bullet(pos: Vector2, dir: Vector2, speed: float = 100):
	var bullet = bullet_node.instantiate()
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
	return true

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
	var random_upgrades = []
	
	for i in count:
		var random_index = rng().randi_range(0, available_upgrades.size() - 1)
		random_upgrades.append(available_upgrades[random_index])
		available_upgrades.remove_at(random_index)
	
	return random_upgrades
