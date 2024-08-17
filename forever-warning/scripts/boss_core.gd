extends Area2D

@export var life: int = 20
@export var speed: float = 300
@export var shoot_frequency: float = 1.0
@export var base_chance_to_fire: float = 0.0

@onready var player = $"../Player"
@onready var shoot_timer = $ShootTimer

var bullet_node := preload("res://scenes/boss_bullet.tscn")
var rng = RandomNumberGenerator.new()
var chance_to_fire: float

func _ready():
	chance_to_fire = base_chance_to_fire

func _process(_delta):
	if shoot_timer.is_stopped():
		shoot_timer.start(shoot_frequency)
		var rand = rng.randf()
		print(rand)
		if rand > chance_to_fire:
			shoot()

func damage(amount: int):
	life -= amount
	if life < 0:
		queue_free()

func shoot():
	# TODO: Have multiple possible attacks
	if rng.randf() > 10.5:
		shoot_one_bullet_toward_player()
	else:
		shoot_bullets_in_circle(10)

func shoot_one_bullet_toward_player():
	# Shoot bullet toward player
	if player != null:
		var direction = (player.global_position - global_position).normalized()
		instantiate_bullet(direction)
	pass
	
func instantiate_bullet(dir: Vector2):
	var bullet = bullet_node.instantiate()
	bullet.global_position = global_position
	bullet.set_direction(dir)
	get_tree().current_scene.add_child(bullet)

func shoot_bullets_in_circle(count: int):
	for i:float in count:
		var angle = ((i / count) * 360) * (PI/180.0)
		var direction = Vector2(sin(angle), cos(angle))
		instantiate_bullet(direction)
