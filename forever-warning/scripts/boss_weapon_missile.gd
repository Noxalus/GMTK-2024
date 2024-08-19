extends BossWeapon

const BOSS_MISSILE = preload("res://scenes/bullets/boss_missile.tscn")

func shoot():
	# instantiate an homing missile
	var instance = BOSS_MISSILE.instantiate()
	instance.global_position = bullet_spawn.global_position
	instance.global_rotation = bullet_spawn.global_rotation
	get_tree().current_scene.add_child(instance)
