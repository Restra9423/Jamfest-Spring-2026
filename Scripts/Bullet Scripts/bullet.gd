class_name Bullet
extends Area2D

@export var speed : float = 200.0
@export_range(0, 360) var angle : float
@export var ownerGroup : String
@export var groupID : int
@export var isLead : bool = false
@export var isParryable : bool
@export var timeToDestroy : float = 20.0
@export var pointValue : int = 100
@export var mySprite : AnimatedSprite2D
@onready var myHitbox : CollisionShape2D = $Hitbox
@onready var destroyTimer : Timer = $DestroyTimer
@onready var startTimer : Timer = $StartTimer
@onready var moveDir : Vector2
@onready var parriedBullet : bool = false
@onready var isOrbiting : bool = false
@onready var visibleOnScreen : VisibleOnScreenNotifier2D = $VisibleOnScreenNotifier2D

enum BulletShapes{
	CIRCLE,
	STAR,
	TRIANGLE,
	DELTA,
	RECTANGLE,
	BOMB,
	LANDMINE
}
@export var myShape: BulletShapes = BulletShapes.CIRCLE

var timeToStart : bool = false

func _ready():
	moveDir = Vector2.RIGHT.rotated(deg_to_rad(angle))
	destroyTimer.wait_time = timeToDestroy
	destroyTimer.start()

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
			# Become blue
			mySprite.frame = 0
		false:
			# Become red
			mySprite.frame = 1

func _process(delta):
	if timeToStart:
		translate(moveDir * speed * delta)

func _physics_process(_delta: float) -> void:
	for area in get_overlapping_areas():
		if(area.is_in_group("bullets")):
			if(parriedBullet && isParryable && !area.isParryable && !area.parriedBullet):
				ScoreCounter.incrementScore(area.pointValue)
				ScoreManager.instance.updateScore()
				ScoreManager.instance.makePointDisplay(area.global_position, area.pointValue, "Ricochet")
				area.setParried(self.position.direction_to(area.position).normalized())

func _on_start_timer_timeout() -> void:
	timeToStart = true

func _on_destroy_timer_timeout() -> void:
	timeToStart = false
	myHitbox.set_deferred("disabled", true)
	var tween = create_tween()
	tween.tween_property(mySprite, "modulate:a", 0.0, 1.0)
	await tween.finished
	queue_free()

func setParried(parriedDir: Vector2):
	mySprite.frame = 2
	destroyTimer.start()
	speed = (speed * 1.3) + 300
	moveDir = (-(moveDir) + (parriedDir * 2)).normalized()
	parriedBullet = true
	if get_parent().has_method("onChildParried"):
		get_parent().onChildParried(groupID, global_position)
	elif has_meta("parentPattern") && is_instance_valid(get_meta("parentPattern")):
		get_meta("parentPattern").onChildParried(groupID, global_position)

func onDestroyed() -> void:
	if get_parent().has_method("onBulletDestroyed"):
		get_parent().onBulletDestroyed(self)
	if get_parent().has_method("onChildParried"):
		get_parent().onChildParried(groupID, global_position)
	queue_free()

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	if (parriedBullet):
		queue_free()
