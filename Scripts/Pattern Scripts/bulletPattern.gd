class_name BulletPattern
extends Node2D

@export var patternShape: Bullet.BulletShapes
@export var groupParryValue : int
@export var totalWaves : int = 0

func _ready() -> void:
	for child in get_children():
		if child is Bullet:
			child.initializeSprite(patternShape)
			if totalWaves > 0:
				child.speed *= (1.01 * totalWaves)
			if child.groupID == 0:
				child.reparent.call_deferred(get_parent())
		else:
			child.reparent.call_deferred(get_parent())
	if !hasGroupedBullets():
		queue_free.call_deferred()

func onChildParried(groupID: int) -> void:
	for child in get_children():
		if child is Bullet && child.groupID == groupID && child.parriedBullet:
			child.reparent.call_deferred(get_parent())
	for child in get_children():
		if child is Bullet && child.groupID == groupID && !child.parriedBullet:
			return
	onAllParried(groupID)

func onAllParried(groupID: int) -> void:
	AudioController.playSFX(AudioController.chainSound)
	ScoreCounter.incrementScore(groupParryValue)
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
