class_name BulletPattern
extends Node2D

@export var groupParryValue : int
@export var spawnCooldown : float = 0.0
@export var patternType : String
@export var allowedRotations : Array[float] = [0.0]
@export var canBeMirrored : bool = false

var appliedRotation : float = 0.0
var appliedMirrorX : bool = false
var appliedMirrorY : bool = false

var groups : Dictionary = {}
var groupInvalidated : Dictionary = {}

func _ready() -> void:
	for child in get_children():
		
		#initialize bullets
		if child is Bullet:
			
			#initialize bullet sprite
			child.initializeSprite(child.myShape)
			
			#reparent ungrouped bullets, catalog grouped bullets, set homing targets
			if child.groupID == 0:
				applyTransform(child)
				if "target" in child:
					child.setTarget(get_tree().get_first_node_in_group("Player"))
				child.reparent.call_deferred(get_parent())
			else:
				var id = child.groupID
				if id not in groups:
					groups[id] = []
				applyTransform(child)
				if "target" in child:
					if groups[id].size() > 0:
						child.setTarget(groups[id].back())
					else:
						child.setTarget(get_tree().get_first_node_in_group("Player"))
				groups[id].append(child)
				child.set_meta("parentPattern", self)
		else:
			child.reparent.call_deferred(get_parent())
	
	#delete pattern if it has no grouped bullets
	if !hasGroupedBullets():
		queue_free.call_deferred()

func setBulletSpeed(totalWaves: int, currentDifficulty: int) -> void:
	for child in get_children():
		if child is Bullet && !child.staticSpeed:
			#set bullet speed
			if currentDifficulty == 1:
				child.speed *= 0.8
			elif totalWaves > 0:
				child.speed *= pow(1.001, totalWaves)

func applyTransform(bullet: Bullet) -> void:
	if appliedRotation != 0.0:
		bullet.position = bullet.position.rotated(deg_to_rad(appliedRotation))
		bullet.moveDir = bullet.moveDir.rotated(deg_to_rad(appliedRotation))
	if appliedMirrorX:
		bullet.position.x = -bullet.position.x
		bullet.moveDir.x = -bullet.moveDir.x
	if appliedMirrorY:
		bullet.position.y = -bullet.position.y
		bullet.moveDir.y = -bullet.moveDir.y

func onChildParried(groupID: int, childPos : Vector2) -> void:
	for child in get_children():
		if is_instance_valid(child) && "target" in child:
			if !is_instance_valid(child.target) || (child.target is Bullet && child.target.parriedBullet):
				child.setTarget(get_tree().get_first_node_in_group("Player"))
	for child in get_children():
		if child is Bullet && child.groupID == groupID && child.parriedBullet:
			child.reparent.call_deferred(get_parent())
	var bulletGroup = groups.get(groupID, [])
	for bullet in bulletGroup:
		if is_instance_valid(bullet) && !bullet.parriedBullet:
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
		pass
	else:
		AudioController.playSFX(AudioController.chainSound)
		ScoreCounter.incrementScore(groupParryValue)
		ScoreManager.instance.makePointDisplay(childPos + Vector2(0, -100), groupParryValue, "Bonus")
		var player = get_tree().get_first_node_in_group("Player")
		if is_instance_valid(player):
			player.scoreManager.updateScore()
	
	# check ALL groups before freeing pattern
	for id in groups:
		var group = groups[id]
		for bullet in group:
			if is_instance_valid(bullet) && !bullet.parriedBullet:
				return
	queue_free.call_deferred()

func hasGroupedBullets() -> bool:
	for child in get_children():
		if child is Bullet && child.groupID > 0:
			return true
	return false
