extends HomingBullet
class_name JellyfishBullet

@export var burstSpeed : float
@export var driftSpeed : float
@export var transitionDuration : float

var isBursting : bool = true
var speedTween : Tween = null

func _ready() -> void:
	super._ready()
	speed = burstSpeed

func _process(delta: float) -> void:
	if parriedBullet:
		if is_instance_valid(indicator):
			indicator.queue_free()
			indicator = null
		if timeToStart:
			translate(moveDir * speed * delta)
			mySprite.rotation = (moveDir.angle() + 1.5)
		return
	
	var onScreen = screenNotifier.is_on_screen()
	var player = get_tree().get_first_node_in_group("Player")
	var playerMoving = is_instance_valid(player) && player.velocity.length() > 100.0
	
	if onScreen:
		if playerMoving && !isBursting:
			# player started moving, switch to burst
			isBursting = true
			if is_instance_valid(target):
				moveDir = (target.global_position - global_position).normalized()
			transitionSpeed(burstSpeed)
		elif !playerMoving && isBursting:
			# player stopped, switch to drift
			isBursting = false
			transitionSpeed(driftSpeed)
	else:
		if !isBursting:
			# always burst offscreen
			isBursting = true
			if is_instance_valid(target):
				moveDir = (target.global_position - global_position).normalized()
			transitionSpeed(burstSpeed)
	
	if timeToStart && targetSet:
		if is_instance_valid(target) && !parriedBullet:
			var distanceToTarget = global_position.distance_to(target.global_position)
			var targetDir = (target.global_position - global_position).normalized()
			
			var effectiveTurnSpeed = turnSpeed
			if isBursting && !target.is_in_group("Player"):
				effectiveTurnSpeed = turnSpeed * clamp(minDistance * 2 / distanceToTarget, 1.0, 5.0)
			
			if isBursting:
				moveDir = moveDir.rotated(clamp(moveDir.angle_to(targetDir), -effectiveTurnSpeed * delta, effectiveTurnSpeed * delta))
			
			if !target.is_in_group("Player") && distanceToTarget < minDistance * 2:
				var proximityFactor = (distanceToTarget - minDistance) / minDistance
				proximityFactor = clamp(proximityFactor, 0.05, 1.0)
				translate(moveDir * speed * proximityFactor * delta)
			else:
				translate(moveDir * speed * delta)
		else:
			if !is_instance_valid(target):
				setTarget(get_tree().get_first_node_in_group("Player"))
			translate(moveDir * speed * delta)
		
		mySprite.rotation = (moveDir.angle() + 1.5)
		
		if !onScreen && is_instance_valid(target) && target.is_in_group("Player") && !parriedBullet:
			if _isWithinIndicatorRange() && !is_instance_valid(indicator):
				indicator = offscreenIndicator.instantiate()
				indicator.visible = false
				get_tree().root.get_node("WorldScene").add_child(indicator)
				_updateIndicator()
				indicator.visible = true
		
		if is_instance_valid(indicator) && is_instance_valid(target) && target.is_in_group("Player"):
			if _isWithinIndicatorRange():
				_updateIndicator()
			else:
				indicator.queue_free()
				indicator = null

func transitionSpeed(targetSpeed: float) -> void:
	if speedTween:
		speedTween.kill()
	speedTween = create_tween()
	speedTween.tween_property(self, "speed", targetSpeed, transitionDuration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

func setParried(parriedDir: Vector2):
	if speedTween:
		speedTween.kill()
		speedTween = null
	super.setParried(parriedDir)
	speed = max(speed, 200.0)

func setTarget(newTarget: Node2D) -> void:
	super.setTarget(newTarget)
