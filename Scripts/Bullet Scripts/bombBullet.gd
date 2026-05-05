extends Bullet

@export var myShader : ShaderMaterial
@export var shrapnelCount : int = 8
@export var shrapnelType : PackedScene

func _ready() -> void:
	super._ready()
	myShader = myShader.duplicate()
	mySprite.material = myShader
	setHue(0.1)

func _process(delta):
	if timeToStart:
		translate(moveDir * speed * delta)
		if destroyTimer.time_left < 2.0:
			if fmod(destroyTimer.time_left, 0.5) < 0.25:
				setHue(0.1)  # original color
			else:
				setHue(0.45)  # orange shift

func setHue(value : float) -> void:
	myShader.set_shader_parameter("hue_shift", value)

func _on_destroy_timer_timeout() -> void:
	timeToStart = false
	myHitbox.set_deferred("disabled", true)
	explode()
	queue_free()

func setParried(parriedDir: Vector2):
	destroyTimer.start()
	explode()
	parriedBullet = true
	if get_parent().has_method("onChildParried"):
		get_parent().onChildParried(groupID)
	queue_free()

func explode() -> void:
	var angleStep = 360.0 / shrapnelCount
	for i in shrapnelCount:
		var shrapnel = shrapnelType.instantiate()
		get_parent().add_child(shrapnel)
		shrapnel.initializeSprite(shrapnel.myShape)
		if "target" in shrapnel:
			shrapnel.setTarget(get_tree().get_first_node_in_group("Player"))
		shrapnel.global_position = global_position
		shrapnel.angle = 180 + (angleStep * i)
		shrapnel.moveDir = Vector2.RIGHT.rotated(deg_to_rad(shrapnel.angle))
