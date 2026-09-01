extends Bullet
class_name BombBullet

@export var shrapnelCount : int = 8
@export var explosionAngle : float = 0.0
@export var shrapnelType : PackedScene
@export var shrapnelIndicator : PackedScene
var indicators : Array = []
var indicatorRadius : float = 0.0

func _ready() -> void:
	super._ready()
	# set indicator radius based on sprite size
	indicatorRadius = mySprite.sprite_frames.get_frame_texture("bomb", 0).get_width() / 6.5
	_createIndicators()

func _createIndicators() -> void:
	var angleStep = 360.0 / shrapnelCount
	for i in shrapnelCount:
		var indicator = shrapnelIndicator.instantiate()
		add_child(indicator)
		indicator.visible = false
		indicators.append(indicator)
		var angle = deg_to_rad(explosionAngle + (angleStep * i))
		var offset = Vector2.RIGHT.rotated(angle) * indicatorRadius
		indicator.position = offset
		indicator.rotation = angle + PI/2

func _process(delta):
	if timeToStart:
		translate(moveDir * speed * delta)
		if destroyTimer.time_left < 2.0:
			if destroyTimer.time_left < 0.5:
				for indicator in indicators:
					if is_instance_valid(indicator):
						indicator.visible = true
				if fmod(destroyTimer.time_left, 0.1) < 0.05:
					if parriedBullet:
						mySprite.frame = 2
					else:
						mySprite.frame = 0
				else:
					if parriedBullet:
						mySprite.frame = 3
					else:
						mySprite.frame = 1
			elif fmod(destroyTimer.time_left, 0.5) < 0.25:
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
	for indicator in indicators:
		if is_instance_valid(indicator):
			indicator.queue_free()
	indicators.clear()
	timeToStart = false
	myHitbox.set_deferred("disabled", true)
	explode()
	if has_meta("parentPattern") && is_instance_valid(get_meta("parentPattern")):
		get_meta("parentPattern").onChildParried(groupID, global_position)
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
		return
	var angleStep = 360.0 / shrapnelCount
	var pattern = get_meta("parentPattern") if has_meta("parentPattern") && is_instance_valid(get_meta("parentPattern")) else null
	var spawnParent = pattern.get_parent() if pattern else get_parent()
	for i in shrapnelCount:
		var shrapnel = shrapnelType.instantiate()
		spawnParent.add_child(shrapnel)
		shrapnel.initializeSprite(shrapnel.myShape)
		if "target" in shrapnel:
			shrapnel.setTarget(get_tree().get_first_node_in_group("Player"))
		shrapnel.global_position = global_position
		shrapnel.angle = explosionAngle + (angleStep * i)
		shrapnel.moveDir = Vector2.RIGHT.rotated(deg_to_rad(shrapnel.angle))
		shrapnel.groupID = groupID
		if pattern:
			shrapnel.set_meta("parentPattern", pattern)
			pattern.groups[groupID].append(shrapnel)
