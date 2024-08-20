extends RayCast2D

var is_casting := false
var tween: Tween

func _ready() -> void:
	tween = create_tween()
	set_physics_process(false)
	$Line2D.points[1] = Vector2.ZERO
	
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("focus"):
		set_is_casting(not is_casting)

func _physics_process(delta: float) -> void:
	var cast_point := target_position
	force_raycast_update()
	
	$CastingParticle.emitting = is_colliding()
	
	if is_colliding():
		cast_point = to_local(get_collision_point())
		$CastingParticle.position = cast_point
		$CastingParticle.global_rotation = get_collision_normal().angle() - PI / 2.0
	
	$Line2D.points[1] = cast_point

func set_is_casting(cast: bool) -> void:
	is_casting = cast
	
	$BeamParticle.emitting = is_casting
	
	if is_casting:
		appear()
	else:
		$CastingParticle.emitting = false
		disappear()
		
	set_physics_process(is_casting)

func appear() -> void:
	print("APPEAR")
	if tween:
		tween.kill()
	tween = create_tween()
	tween.tween_property($Line2D, "width", 10, 0.2)

func disappear() -> void:
	print("DISAPPEAR")
	if tween:
		tween.kill()
	tween = create_tween()
	tween.tween_property($Line2D, "width", 0.0, 0.1)
