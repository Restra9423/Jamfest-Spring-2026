extends Bullet
class_name BombBullet

@export var shrapnelCount : int = 8
@export var explosionAngle : float = 0.0
@export var shrapnelType : PackedScene

func _process(delta):
	if timeToStart:
		translate(moveDir * speed * delta)
		if destroyTimer.time_left < 2.0:
			if fmod(destroyTimer.time_left, 0.5) < 0.25:
				if parriedBullet:
					mySprite.frame = 2
				else:
					mySprite.frame = 0
			else:
				if parriedBullet:
					mySprite.frame = 3
				else:
					mySprite.frame = 1

func _on_destroy_timer_timeout() -> void:
	timeToStart = false
	myHitbox.set_deferred("disabled", true)
	explode()
	queue_free()

func setParried(parriedDir: Vector2):
	mySprite.frame = 2
	if destroyTimer.time_left < 0.5:
		destroyTimer.wait_time = 0.5
		destroyTimer.start()
	speed = (speed * 1.5) + 200
	moveDir = (-(moveDir) + (parriedDir * 2)).normalized()
	parriedBullet = true
	if get_parent().has_method("onChildParried"):
		get_parent().onChildParried(groupID, global_position)

func explode() -> void:
	if !is_visible_in_tree():
		queue_free()
	var angleStep = 360.0 / shrapnelCount
	for i in shrapnelCount:
		var shrapnel = shrapnelType.instantiate()
		get_parent().add_child(shrapnel)
		shrapnel.initializeSprite(shrapnel.myShape)
		if "target" in shrapnel:
			shrapnel.setTarget(get_tree().get_first_node_in_group("Player"))
		shrapnel.global_position = global_position
		shrapnel.angle = explosionAngle + (angleStep * i)
		shrapnel.moveDir = Vector2.RIGHT.rotated(deg_to_rad(shrapnel.angle))
