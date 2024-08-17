extends Area2D

@export var life: int = 20
@export var speed: float = 300
@export var shoot_frequency: float = 1.0
@export var base_chance_to_fire: float = 0.5

@onready var player = $"../Player"
@onready var shoot_timer = $ShootTimer
@onready var parts_side_slots = [$BossPartSlots/BossPartSlot1_L, $BossPartSlots/BossPartSlot1_R]
@onready var parts_down_slots = [$BossPartSlots/BossPartSlot2_L, $BossPartSlots/BossPartSlot2_R]
@onready var parts_up_slots = [$BossPartSlots/BossPartSlot3_L, $BossPartSlots/BossPartSlot3_R]

signal died_signal

var bullet_node := preload("res://scenes/boss_bullet.tscn")
var rng = RandomNumberGenerator.new()
var chance_to_fire: float
var is_dead = false

func _ready():
	chance_to_fire = base_chance_to_fire
	
func _process(_delta):
	if is_dead:
		return
		 
	if shoot_timer.is_stopped():
		shoot_timer.start(shoot_frequency)
		var rand = rng.randf()
		print(rand)
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

func setup(wave_count: int):
	life = 20
	visible = true
	is_dead = false
	spawn_new_parts()
	spawn_new_weapons()

func spawn_new_parts():
	pass

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
