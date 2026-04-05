extends Area2D

@export var speed : float = 200.0
@export_range(0, 360) var angle : float
@export var ownerGroup : String
@export var isParryable : bool
@export var timeToDestroy : float
@onready var destroyTimer : Timer = $DestroyTimer
@onready var startTimer : Timer = $StartTimer
@onready var moveDir : Vector2

var timeToStart : bool = false

func _ready():
	moveDir = Vector2.RIGHT.rotated(deg_to_rad(angle))
	destroyTimer.wait_time = timeToDestroy
	destroyTimer.start()

func _process (delta):
	if (timeToStart):
		translate(moveDir * speed * delta)

func _on_body_entered(body: Node2D) -> void:
	queue_free()

func _on_start_timer_timeout() -> void:
	timeToStart = true

func _on_destroy_timer_timeout() -> void:
	queue_free()
