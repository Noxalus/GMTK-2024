extends Node2D

# Assets preloading
var boss_core = preload("res://scenes/boss_core.tscn")
var boss_parts = [
	preload("res://scenes/boss_part_1.tscn"),
	preload("res://scenes/boss_part_2.tscn")
]
var boss_weapons = [
	preload("res://scenes/boss_weapon_turret.tscn")
]
var bullet_node := preload("res://scenes/boss_bullet.tscn")

var local_rng = RandomNumberGenerator.new()
var wave_count: int = 0
var boss = null
var player = null

func _ready():
	spawn_new_boss()

func _process(delta):
	if Input.is_action_just_pressed("next_boss") and boss != null:
		boss.damage(9999)

func spawn_new_boss():
	if boss == null:
		boss = boss_core.instantiate()
		get_tree().current_scene.add_child(boss)
		boss.died_signal.connect(_on_boss_death)
		boss.visible = false
	else:
		boss.setup()
	
	boss.position = Vector2(0, -175)

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
	
func rng():
	return local_rng
