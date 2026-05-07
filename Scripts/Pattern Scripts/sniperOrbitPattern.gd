extends OrbitPattern
class_name SniperOrbitPattern

@export var fireRate : float = 2.0
var fireTimer : float = 0.0

func _process(delta: float) -> void:
	super._process(delta)
	
	for id in groups:
		var bulletGroup = groups[id]
		if bulletGroup.size() < 2:
			continue
		
		var lead = bulletGroup[0]
		if !is_instance_valid(lead) || !lead.isLead || lead.parriedBullet:
			continue
		
		# only fire if lead is on screen
		if !lead.get_node("VisibleOnScreenNotifier2D").is_on_screen():
			continue
		
		fireTimer += delta
		if fireTimer >= fireRate:
			fireTimer = 0.0
			fireSniper(bulletGroup)

func fireSniper(bulletGroup: Array) -> void:
	var player = get_tree().get_first_node_in_group("Player")
	if !is_instance_valid(player):
		return
	
	# find first valid orbiting bullet
	for i in range(1, bulletGroup.size()):
		var bullet = bulletGroup[i]
		if !is_instance_valid(bullet) || bullet.parriedBullet:
			continue
		
		# free from orbit and aim at player
		bullet.timeToStart = true
		if "shrapnelCount" in bullet:
				# bomb bullet - unpause destroy timer
				bullet.destroyTimer.paused = false
		bullet.moveDir = (player.global_position - bullet.global_position).normalized()
		orbitAngles.erase(bullet)
		bulletGroup.remove_at(i)
		bullet.reparent(get_parent())
		break
