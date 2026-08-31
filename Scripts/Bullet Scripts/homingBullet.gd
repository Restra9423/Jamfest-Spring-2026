extends Bullet
class_name HomingBullet

@export var turnSpeed : float = 2.0
@export var minDistance : float = 50.0
@export var offscreenIndicator : PackedScene
@onready var screenNotifier : VisibleOnScreenNotifier2D = $VisibleOnScreenNotifier2D

var target : Node2D
var targetSet : bool = false
var indicator : Node2D = null
var margin : float = 90.0


func _ready() -> void:
	super._ready()
	await get_parent().ready
	
	if !screenNotifier.is_on_screen() && is_instance_valid(target) && target.is_in_group("Player") && _isWithinIndicatorRange():
		indicator = offscreenIndicator.instantiate()
		indicator.visible = false
		get_tree().root.get_node("WorldScene").add_child.call_deferred(indicator)
		
		await indicator.tree_entered
		_updateIndicator()
		indicator.visible = true

func _process(delta):
	if parriedBullet && is_instance_valid(indicator):
		indicator.queue_free()
		indicator = null
	if timeToStart && targetSet:
		if is_instance_valid(target) && !parriedBullet:
			var distanceToTarget = global_position.distance_to(target.global_position)
			var targetDir = (target.global_position - global_position).normalized()
			
			var effectiveTurnSpeed = turnSpeed
			if !target.is_in_group("Player"):
				effectiveTurnSpeed = turnSpeed * clamp(minDistance * 2 / distanceToTarget, 1.0, 5.0)
			
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
		
		if is_instance_valid(indicator) && is_instance_valid(target) && target.is_in_group("Player"):
			if _isWithinIndicatorRange():
				_updateIndicator()
			else:
				indicator.queue_free()
				indicator = null
		
		# spawn indicator when bullet enters range while offscreen
		if !screenNotifier.is_on_screen() && is_instance_valid(target) && target.is_in_group("Player") && !parriedBullet:
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

func setTarget(newTarget : Node2D):
	if parriedBullet: return
	target = newTarget
	if !isOrbiting:
			if target.is_in_group("Player"):
				mySprite.frame = 0 if isParryable else 1
			else:
				mySprite.frame = 3 if isParryable else 4
	moveDir = (target.global_position - global_position).normalized()
	targetSet = true

func _on_visible_on_screen_notifier_2d_screen_entered() -> void:
	if is_instance_valid(indicator):
		indicator.queue_free()
		indicator = null

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	if parriedBullet:
		if is_instance_valid(indicator):
			indicator.queue_free()
			indicator = null
		if get_parent().has_method("onChildParried") && get_parent() is BulletPattern:
			get_parent().onChildParried(groupID, global_position)
		queue_free()
		return
	
	if is_instance_valid(target) && target.is_in_group("Player"):
		if _isWithinIndicatorRange():
			indicator = offscreenIndicator.instantiate()
			indicator.visible = false
			get_tree().root.get_node("WorldScene").add_child(indicator)
			_updateIndicator()
			indicator.visible = true

func _updateIndicator() -> void:
	if !is_instance_valid(indicator):
		return
	
	var dirToIndicator = global_position.normalized()
	var edgePos = _getScreenEdgePosition(dirToIndicator)
	
	indicator.global_position = edgePos
	indicator.rotation = dirToIndicator.angle() - PI/2
	
	var indicatorSprite = indicator.get_node("BulletSprite")
	if is_instance_valid(indicatorSprite):
		indicatorSprite.animation = mySprite.animation
		indicatorSprite.frame = mySprite.frame
		indicatorSprite.rotation = mySprite.rotation - indicator.rotation
		indicatorSprite.scale = Vector2(0.5, 0.5)

func _getScreenEdgePosition(direction: Vector2) -> Vector2:
	# play area extends ±960 units from world origin
	var halfWidth = 960.0 - margin
	var halfHeight = 960.0 - margin
	
	var tMin = INF
	
	if direction.x != 0:
		var tLeft = -halfWidth / direction.x
		var tRight = halfWidth / direction.x
		if tLeft > 0:
			tMin = min(tMin, tLeft)
		if tRight > 0:
			tMin = min(tMin, tRight)
	if direction.y != 0:
		var tTop = -halfHeight / direction.y
		var tBottom = halfHeight / direction.y
		if tTop > 0:
			tMin = min(tMin, tTop)
		if tBottom > 0:
			tMin = min(tMin, tBottom)
	
	return direction * tMin

func _isWithinIndicatorRange() -> bool:
	# distance from world origin to bullet, minus the screen half-size
	var distanceFromEdge = global_position.length() - 960.0
	return distanceFromEdge <= 1000.0
