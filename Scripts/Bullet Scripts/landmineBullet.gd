extends Bullet
class_name LandmineBullet

func setParried(parriedDir: Vector2):
	destroyTimer.start()
	speed = (speed * 1.5) + 200
	moveDir = (-(moveDir) + (parriedDir * 2)).normalized()
	if get_parent().has_method("onChildParried"):
		get_parent().onChildParried(groupID)
