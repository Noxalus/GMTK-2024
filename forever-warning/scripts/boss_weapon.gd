extends Area2D

class_name BossWeapon

@export var shoot_frequency_min: float = 0.1
@export var shoot_frequency_max: float = 1.75
@export var base_chance_to_fire: float = 0.5
@export var rotation_speed_min: float = 0.5
@export var rotation_speed_max: float = 7.5
@export var base_bullet_speed: float = 500
@export var base_life: int = 10
@onready var bullet_spawn: Node2D = $BulletSpawn

signal died_signal

var life

@onready var shoot_timer = $ShootTimer

var speed: float
var is_dead = false # dead by default
var direction: Vector2
var rotation_speed: float = 0.1
var is_flipped = false

func _ready():
	speed = base_bullet_speed
	life = base_life
	set_new_random_shoot_delay()
	rotation_speed = game.rng().randf_range(rotation_speed_min, rotation_speed_max)

func setup():
	life = base_life
	visible = true
	is_dead = false

func _process(delta):
	if is_dead or game.player.is_dead or game.is_paused or game.boss.is_spawning:
		return
		
	if game.player != null:
		var target_direction = (game.player.global_position - global_position).normalized()
		direction = lerp(direction, target_direction, rotation_speed * delta)
		direction = direction.normalized()
		var angle_offset = PI / 2.0
		if is_flipped:
			angle_offset += PI
		set_global_rotation(direction.angle() + angle_offset)
	
	if shoot_timer != null and shoot_timer.is_stopped():
		set_new_random_shoot_delay()
		var rand = game.rng().randf()
		if rand <= base_chance_to_fire:
			shoot()

func set_new_random_shoot_delay():
	var shoot_frequency_factor = pow(game.wave_count, 0.25)
	var random_shoot_frequency = game.rng().randi_range(shoot_frequency_min, shoot_frequency_max) * shoot_frequency_factor
	#print("delay factor: %s" % shoot_frequency_factor)
	#print("delay: %s" % random_shoot_frequency)
	shoot_timer.start(random_shoot_frequency * shoot_frequency_factor)

func damage(amount: int):
	life -= amount
	if life < 0:
		kill()

func kill():
	visible = false
	is_dead = true
	died_signal.emit()
	game.spawn_explosion(global_position)

func shoot():
	game.instantiate_bullet(bullet_spawn.global_position, direction, speed)
	$ShootSound.play()
