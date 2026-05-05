extends Bullet

func _process (delta):
	if (timeToStart):
		translate(moveDir * speed * delta)
		for body in get_overlapping_bodies():
			if body.is_in_group("Player"):
				var pushDir = (body.global_position - global_position).normalized()
				var projection = pushDir.dot(moveDir)
				if projection > 0:
					body.velocity = 4 * moveDir * speed

func setParried(_parriedDir: Vector2):
	return
