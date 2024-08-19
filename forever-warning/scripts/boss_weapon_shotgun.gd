extends BossWeapon

func _ready() -> void:
	super._ready()
	shoot_frequency_min = 1
	shoot_frequency_max = 5

func shoot():
	var base_direction = direction
	for i in range(0, 10):
		# spread
		var base_angle = base_direction.angle()
		var spread_angle = base_angle + game.rng().randf_range(-1.0, 1.0) * (PI / 10.0)
		var dir = Vector2.from_angle(spread_angle)
		var spd = speed / 5.0 + game.rng().randf_range(-1.0, 1.0) * (speed / 20.0)
		game.instantiate_bullet(bullet_spawn.global_position, dir, spd, 1)
		$ShootSound.play()
