extends BossWeapon

@onready var bullet_space_timer: Timer = $BulletSpaceTimer

var bullet_delay := 0.1

func shoot():
	for i in range(0, 5):	
		game.instantiate_bullet(bullet_spawn.global_position, direction, speed, 2)
		$ShootSound.play()
		# Wait between each bullet
		var timer := get_tree().create_timer(bullet_delay)
		await timer.timeout
