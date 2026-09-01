extends Bullet
class_name BouncyBullet

@export var bounceRandomness : float = 0.2  # radians of random angle deviation
@export var maxBounces : int = -1  # -1 for infinite bounces
var bounceCount : int = 0
var hasEnteredScreen : bool = false
var enterTimer : float = 0.0
var enterDelay : float

func initializeSprite(shape: BulletShapes):
	match shape:
		BulletShapes.CIRCLE:
			mySprite.animation="circle"
		BulletShapes.STAR:
			mySprite.animation="star"
		BulletShapes.TRIANGLE:
			mySprite.animation="triangle"
		BulletShapes.DELTA:
			mySprite.animation="delta"
		BulletShapes.RECTANGLE:
			mySprite.animation="rectangle"
		BulletShapes.BOMB:
			mySprite.animation="bomb"
		BulletShapes.LANDMINE:
			mySprite.animation="landmine"
	match isParryable:
		true:
			# Become green
			mySprite.frame = 3
		false:
			# Become red
			mySprite.frame = 1

func _ready() -> void:
	super._ready()
	var bulletWidth = mySprite.sprite_frames.get_frame_texture(mySprite.animation, 0).get_width()
	enterDelay = bulletWidth / speed

func _process(delta: float) -> void:
	if timeToStart:
		if hasEnteredScreen:
			_checkBounce()
		elif visibleOnScreen.is_on_screen():
			enterTimer += delta
			if enterTimer >= enterDelay:
				hasEnteredScreen = true
		translate(moveDir * speed * delta)

func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	if !timeToStart || !hasEnteredScreen:
		return
	for area in get_overlapping_areas():
		if area.is_in_group("bullets") && area != self && area is BouncyBullet:
			var bounceDir = (global_position - area.global_position).normalized()
			moveDir = bounceDir.rotated(randf_range(-bounceRandomness, bounceRandomness)).normalized()
			bounceCount += 1
			if maxBounces >= 0 && bounceCount >= maxBounces:
				parriedBullet = true
			break

func _checkBounce() -> void:
	var halfWidth = 960.0
	var halfHeight = 960.0
	
	if parriedBullet:
		return
	
	# check if bullet is outside or at screen edge
	if global_position.x <= -halfWidth || global_position.x >= halfWidth:
		moveDir.x = -moveDir.x
		moveDir = moveDir.rotated(randf_range(-bounceRandomness, bounceRandomness))
		moveDir = moveDir.normalized()
		bounceCount += 1
	
	if global_position.y <= -halfHeight || global_position.y >= halfHeight:
		moveDir.y = -moveDir.y
		moveDir = moveDir.rotated(randf_range(-bounceRandomness, bounceRandomness))
		moveDir = moveDir.normalized()
		bounceCount += 1
	
	# exit screen if max bounces reached
	if maxBounces >= 0 && bounceCount >= maxBounces:
		parriedBullet = true

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	if parriedBullet:
		queue_free()
