extends BulletPattern

var groups : Dictionary = {}

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
				var id = child.groupID
				if id not in groups:
					groups[id] = []
				groups[id].append(child)
		else:
			child.reparent.call_deferred(get_parent())
	if hasGroupedBullets():
		for id in groups:
			var bulletGroup = groups[id]
			for i in bulletGroup.size():
				if i > 0:
					bulletGroup[i].target = bulletGroup[i - 1]
	else:
		queue_free.call_deferred()

func onChildParried(groupID: int) -> void:
	for child in get_children():
		if is_instance_valid(child) && child.target is Bullet:
			if child.target.parriedBullet:
				child.target = get_tree().get_first_node_in_group("Player")
	for child in get_children():
		if child is Bullet && child.groupID == groupID && child.parriedBullet:
			child.reparent.call_deferred(get_parent())
	for child in get_children():
		if child is Bullet && child.groupID == groupID && !child.parriedBullet:
			return
	onAllParried(groupID)

func hasGroupedBullets() -> bool:
	for child in get_children():
		if child is Bullet && child.groupID > 0:
			return true
	return false
