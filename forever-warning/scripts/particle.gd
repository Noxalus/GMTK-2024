extends GPUParticles2D

func _process(delta):
	if not emitting:
		queue_free()
