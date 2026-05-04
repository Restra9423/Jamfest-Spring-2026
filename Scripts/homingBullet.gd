extends Bullet

@export var turnSpeed : float = 2.0
var target : Node2D
var isLead : bool = false

func _process(delta):
	if timeToStart:
		if (is_instance_valid(target) && !parriedBullet):
			var targetDir = (target.global_position - global_position).normalized()
			moveDir = moveDir.rotated(clamp(moveDir.angle_to(targetDir), -turnSpeed * delta, turnSpeed * delta))
		translate(moveDir * speed * delta)
		mySprite.rotation = (moveDir.angle() + 1.5)
