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

var local_rng = RandomNumberGenerator.new()

const base_player_lives = 3
var player_lives = base_player_lives
var camera = null
var boss = null
var player = null
var hud = null
var wave_count: int = 0
var bullets = []

func _ready():
	spawn_new_boss()

func _process(delta):
	# debug to test boss generation quickly
	if Input.is_action_just_pressed("next_boss") and boss != null:
		boss.damage(9999)

func restart():
	# reset gameplay values
	wave_count = 0
	player_lives = base_player_lives
	
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
		boss.visible = false
	else:
		boss.setup()

func _on_boss_death():
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
		player.respawn()
	pass
