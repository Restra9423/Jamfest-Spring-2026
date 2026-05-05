extends BulletPattern

var groups : Dictionary = {}

func _ready() -> void:
	for child in get_children():
		if child is Bullet:
			#initialize bullet sprites
			child.initializeSprite(child.myShape)
			
			#set bullet speed based on wave number
			if totalWaves > 0:
				child.speed *= (1.01 * totalWaves)
			
			#reparent ungrouped bullets, catalog grouped bullets, set homing targets
			if child.groupID == 0:
				if "target" in child:
					child.setTarget(get_tree().get_first_node_in_group("Player"))
				child.reparent.call_deferred(get_parent())
			else:
				var id = child.groupID
				if id not in groups:
					groups[id] = []
				if "target" in child:
					if groups[id].size() > 0:
						child.setTarget(groups[id].back())
					else:
						child.setTarget(get_tree().get_first_node_in_group("Player"))
				groups[id].append(child)
		else:
			child.reparent.call_deferred(get_parent())
	
	#delete pattern if it has no grouped bullets
	if !hasGroupedBullets():
		queue_free.call_deferred()

func onChildParried(groupID: int) -> void:
	for child in get_children():
		if is_instance_valid(child) && "target" in child:
			if child.target is Bullet && child.target.parriedBullet:
				child.target = get_tree().get_first_node_in_group("Player")
	for child in get_children():
		if child is Bullet && child.groupID == groupID && child.parriedBullet:
			child.reparent.call_deferred(get_parent())
	for child in get_children():
		if child is Bullet && !child.parriedBullet:
			return
	onAllParried(groupID)

func hasGroupedBullets() -> bool:
	for child in get_children():
		if child is Bullet && child.groupID > 0:
			return true
	return false
