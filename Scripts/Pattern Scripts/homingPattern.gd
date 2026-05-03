extends BulletPattern

func _ready() -> void:
	for child in get_children():
		if child is Bullet:
			child.initializeSprite(patternShape)
			child.target = get_tree().get_first_node_in_group("Player")
			if totalWaves > 0:
				child.speed *= (1.01 * totalWaves)
			if child.groupID == 0:
				child.reparent.call_deferred(get_parent())
		else:
			child.reparent.call_deferred(get_parent())
	if !hasGroupedBullets():
		queue_free.call_deferred()
