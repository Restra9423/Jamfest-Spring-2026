extends Area2D

@export var speed : float = 200.0
@export var ownerGroup : String
@onready var destroyTimer : Timer = $DestroyTimer

var moveDir : Vector2

func _process (delta):
	translate(moveDir * speed * delta)

func _on_body_entered(body: Node2D) -> void:
	queue_free()

func _on_destroy_timer_timeout() -> void:
	queue_free()
