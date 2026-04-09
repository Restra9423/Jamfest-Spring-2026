class_name Bullet
extends Area2D

@export var speed : float = 200.0
@export_range(0, 360) var angle : float
@export var ownerGroup : String
@export var isParryable : bool
@export var timeToDestroy : float
@export var pointValue: int = 100
@export var mySprite: AnimatedSprite2D
@onready var destroyTimer : Timer = $DestroyTimer
@onready var startTimer : Timer = $StartTimer
@onready var moveDir : Vector2
@onready var parriedBullet : bool = false
@onready var visibleOnScreen : VisibleOnScreenNotifier2D = $VisibleOnScreenNotifier2D

enum BulletShapes{
	CIRCLE,
	STAR,
	TRIANGLE,
	DELTA
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
	match isParryable:
		true:
			# Become blue
			mySprite.frame = 0
		false:
			# Become red
			mySprite.frame = 1


func _process (delta):
	if (timeToStart):
		translate(moveDir * speed * delta)

func _on_start_timer_timeout() -> void:
	timeToStart = true

func _on_destroy_timer_timeout() -> void:
	queue_free()

func setParried(parriedDir: Vector2):
	mySprite.frame = 2
	speed = (speed * 1.5) + 200
	moveDir = (-(moveDir) + (parriedDir * 2)).normalized()
	parriedBullet = true

func _on_area_entered(area: Area2D) -> void:
	if(area.is_in_group("bullets")):
		if(parriedBullet && isParryable && !area.isParryable && !area.parriedBullet):
			ScoreCounter.incrementScore(area.pointValue)
			ScoreManager.instance.updateScore()
			area.setParried(self.position.direction_to(area.position).normalized())


func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	if (parriedBullet):
		queue_free()
