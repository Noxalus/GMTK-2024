extends BossWeapon

@onready var bullet_space_timer: Timer = $BulletSpaceTimer

var bullet_delay := 0.1

func _ready() -> void:
	super._ready()
	shoot_frequency_min = 2
	shoot_frequency_max = 7.5

func shoot():
	for i in range(0, 5):	
		game.instantiate_bullet(bullet_spawn.global_position, direction, speed, 0)
		$ShootSound.play()
		# Wait between each bullet
		var timer := get_tree().create_timer(bullet_delay)
		await timer.timeout
