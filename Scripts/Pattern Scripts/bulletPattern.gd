class_name BulletPattern
extends Node2D

@export var groupParryValue : int
@export var totalWaves : int = 0
@export var spawnCooldown : float = 0.0

var groups : Dictionary = {}
var groupInvalidated : Dictionary = {}

func _ready() -> void:
	for child in get_children():
		
		#initialize bullets
		if child is Bullet:
			
			#initialize bullet sprite
			child.initializeSprite(child.myShape)
			
			#set bullet speed
			if totalWaves > 0:
				if "shrapnelCount" in child:
					pass
				else:
					child.speed *= pow(1.001, totalWaves)
			
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

func onChildParried(groupID: int, childPos : Vector2) -> void:
	for child in get_children():
		if is_instance_valid(child) && "target" in child:
			if !is_instance_valid(child.target) || (child.target is Bullet && child.target.parriedBullet):
				child.setTarget(get_tree().get_first_node_in_group("Player"))
	for child in get_children():
		if child is Bullet && child.groupID == groupID && child.parriedBullet:
			child.reparent.call_deferred(get_parent())
	for child in get_children():
		if child is Bullet && child.groupID == groupID && !child.parriedBullet:
			return
	onAllParried(groupID, childPos)

func onBulletDestroyed(destroyedBullet: Bullet) -> void:
	for child in get_children():
		if is_instance_valid(child) && "target" in child:
			if child.target == destroyedBullet:
				child.setTarget(get_tree().get_first_node_in_group("Player"))
	groupInvalidated[destroyedBullet.groupID] = true

func onAllParried(groupID: int, childPos : Vector2) -> void:
	if groupInvalidated.get(groupID, false):
		queue_free.call_deferred()
		return
	AudioController.playSFX(AudioController.chainSound)
	ScoreCounter.incrementScore(groupParryValue)
	ScoreManager.instance.makePointDisplay(childPos + Vector2(0, -100), groupParryValue, "Bonus")
	var player = get_tree().get_first_node_in_group("Player")
	if is_instance_valid(player):
		player.scoreManager.updateScore()
	for child in get_children():
		if child is Bullet:
			if child.groupID > 0 && !child.parriedBullet:
					return
	queue_free.call_deferred()

func hasGroupedBullets() -> bool:
	for child in get_children():
		if child is Bullet && child.groupID > 0:
			return true
	return false
