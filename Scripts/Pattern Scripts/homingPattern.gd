extends BulletPattern

func _ready() -> void:
	for child in get_children():
		if child is Bullet:
			child.initializeSprite(patternShape)
			child.target = get_tree().get_first_node_in_group("Player")
		child.reparent(get_parent())
	queue_free()
