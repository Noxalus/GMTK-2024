extends Area2D

@export var shoot_frequency: float = 1.0
@export var base_chance_to_fire: float = 0.5
@export var base_bullet_speed: float = 500

@onready var shoot_timer = $ShootTimer

var speed: float

func _ready():
	speed = base_bullet_speed

func _process(delta):
	if game.player != null:
		look_at(game.player.position)
		rotation += PI / 2.0
	
	if shoot_timer.is_stopped():
		shoot_timer.start(shoot_frequency)
		var rand = game.rng().randf()
		if rand <= base_chance_to_fire:
			shoot()

func shoot():
	game.instantiate_bullet(global_position, Vector2.from_angle(rotation - PI / 2.0), speed)
