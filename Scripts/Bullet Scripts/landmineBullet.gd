extends Bullet
class_name LandmineBullet

@export var myShader : ShaderMaterial

func _ready() -> void:
	super._ready()
	myShader = myShader.duplicate()
	mySprite.material = myShader

func setHue(value : float) -> void:
	myShader.set_shader_parameter("hue_shift", value)

func setParried(parriedDir: Vector2):
	destroyTimer.start()
	speed = (speed * 1.5) + 200
	moveDir = (-(moveDir) + (parriedDir * 2)).normalized()
	if get_parent().has_method("onChildParried"):
		get_parent().onChildParried(groupID)
