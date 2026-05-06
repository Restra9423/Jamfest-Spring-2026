extends Bullet

@export var turnSpeed : float = 2.0
var target : Node2D
var targetSet : bool = false

func _process(delta):
	if timeToStart && targetSet:
		if (is_instance_valid(target) && !parriedBullet):
			var targetDir = (target.global_position - global_position).normalized()
			moveDir = moveDir.rotated(clamp(moveDir.angle_to(targetDir), -turnSpeed * delta, turnSpeed * delta))
		if (!is_instance_valid(target)):
			target = get_tree().get_first_node_in_group("Player")
		translate(moveDir * speed * delta)
		mySprite.rotation = (moveDir.angle() + 1.5)

func setTarget(newTarget : Node2D):
	target = newTarget
	moveDir = (target.global_position - global_position).normalized()
	targetSet = true
