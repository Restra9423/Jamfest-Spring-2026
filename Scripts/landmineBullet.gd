extends Bullet

@export var myShader : ShaderMaterial

func _ready() -> void:
	super._ready()
	myShader = myShader.duplicate()
	mySprite.material = myShader

func setHue(value : float) -> void:
	myShader.set_shader_parameter("hue_shift", value)

func setParried(parriedDir: Vector2):
	mySprite.frame = 2
	setHue(0.0)
	destroyTimer.start()
	speed = (speed * 1.5) + 200
	moveDir = (-(moveDir) + (parriedDir * 2)).normalized()
	parriedBullet = true
	if get_parent().has_method("onChildParried"):
		get_parent().onChildParried(groupID)
