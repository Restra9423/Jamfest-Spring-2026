class_name BulletPattern
extends Node2D

@export var patternShape: Bullet.BulletShapes

func _ready() -> void:
	for child in get_children():
		if child is Bullet:
			child.initializeSprite(patternShape)
		child.reparent(get_parent())
	queue_free()
