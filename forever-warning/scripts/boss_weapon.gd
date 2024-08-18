extends Area2D

class_name BossWeapon

@export var shoot_frequency: float = 1.0
@export var base_chance_to_fire: float = 0.5
@export var base_bullet_speed: float = 500
@export var base_life: int = 10

signal died_signal

var life

@onready var shoot_timer = $ShootTimer

var speed: float
var is_dead = true # dead by default

func _ready():
	speed = base_bullet_speed
	life = base_life

func setup():
	life = base_life
	visible = true
	is_dead = false

func _process(delta):
	if is_dead or game.player.is_dead:
		return
		
	if game.player != null:
		look_at(game.player.position)
		rotation += PI / 2.0
	
	if shoot_timer != null and shoot_timer.is_stopped():
		shoot_timer.start(shoot_frequency)
		var rand = game.rng().randf()
		if rand <= base_chance_to_fire:
			shoot()

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
	game.instantiate_bullet(global_position, Vector2.from_angle(rotation - PI / 2.0), speed)
