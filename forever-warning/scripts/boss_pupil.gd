extends Sprite2D

func _physics_process(delta: float) -> void:
	if game.player == null:
		return
		
	look_at(game.player.position)
	rotation -= PI / 2.0
