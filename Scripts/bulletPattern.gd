extends Node2D

@export var patternShape: Bullet.BulletShapes

func _ready() -> void:
	for child: Bullet in get_children():
		child.initializeSprite(patternShape)
		child.reparent(get_parent())
	queue_free()
