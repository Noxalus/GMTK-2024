extends BossWeapon

const BOSS_MISSILE = preload("res://scenes/bullets/boss_missile.tscn")

func _ready() -> void:
	super._ready()
	shoot_frequency_min = 10
	shoot_frequency_max = 20

func shoot():
	# instantiate an homing missile
	var instance = BOSS_MISSILE.instantiate()
	instance.global_position = bullet_spawn.global_position
	instance.global_rotation = bullet_spawn.global_rotation
	instance.set_speed(game.rng().randi_range(50, 500))
	instance.set_rotation_speed(game.rng().randf_range(0.01, 0.01))
	get_tree().current_scene.add_child(instance)
