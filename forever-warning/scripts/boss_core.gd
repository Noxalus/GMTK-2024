extends Area2D

@export var life: int = 20
@export var speed: float = 300
@export var shoot_frequency: float = 1.0

@onready var player = $"../Player"
@onready var shoot_timer = $ShootTimer

var bullet_node := preload("res://scenes/boss_bullet.tscn")
var rng = RandomNumberGenerator.new()

func _process(_delta):
	if shoot_timer.is_stopped():
		shoot_timer.start(shoot_frequency)
		var rand = rng.randf()
		print(rand)
		if rand > 0.0:
			shoot()

func damage(amount: int):
	life -= amount
	if life < 0:
		queue_free()

func shoot():
	# Shoot bullet toward player
	print("SHOOT")
	var bullet = bullet_node.instantiate()
	bullet.global_position = global_position
	var direction = (player.global_position - global_position).normalized()
	bullet.set_direction(direction)
	get_tree().current_scene.add_child(bullet)
