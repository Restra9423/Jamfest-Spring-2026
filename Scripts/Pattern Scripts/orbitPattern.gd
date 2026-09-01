extends BulletPattern
class_name OrbitPattern

@export var orbitRadius : float = 100.0
@export var orbitSpeed : float = 2.0  # radians per second

var orbitAngles : Dictionary = {}  # tracks each bullet's current angle around its lead

func _ready() -> void:
	super._ready()
	
	# assign initial orbit angles evenly around the lead
	for id in groups:
		var bulletGroup = groups[id]
		var angleStep = TAU / (bulletGroup.size() - 1)  # -1 to exclude lead bullet
		bulletGroup[0].isLead = true
		
		for i in range(1, bulletGroup.size()):
			orbitAngles[bulletGroup[i]] = angleStep * (i - 1)
			bulletGroup[i].timeToStart = false
			bulletGroup[i].isOrbiting = true
			
			if "shrapnelCount" in bulletGroup[i]:
				bulletGroup[i].destroyTimer.paused = true
				# connect screen_exited to free bomb bullet if no longer orbiting
				var bullet = bulletGroup[i]
				bullet.get_node("VisibleOnScreenNotifier2D").screen_exited.connect(
					func():
						if is_instance_valid(bullet) && bullet.timeToStart:
							bullet.queue_free()
				)

func _process(delta: float) -> void:
	for id in groups:
		var bulletGroup = groups[id]
		if bulletGroup.size() < 2:
			continue
		
		var lead = bulletGroup[0]
		if !is_instance_valid(lead) || !lead.isLead || lead.parriedBullet:
			continue
		
		for i in range(1, bulletGroup.size()):
			var bullet = bulletGroup[i]
			if !is_instance_valid(bullet) || bullet.parriedBullet:
				continue
			
			# skip bullets not registered in orbitAngles (e.g. shrapnel)
			if bullet not in orbitAngles:
				continue
			
			#pause timers for orbiting bomb bullets
			if "shrapnelCount" in bullet:
				bullet.destroyTimer.paused = true
			
			orbitAngles[bullet] += orbitSpeed * delta
			var offset = Vector2.RIGHT.rotated(orbitAngles[bullet]) * orbitRadius
			bullet.global_position = lead.global_position + offset
			bullet.moveDir = Vector2.RIGHT.rotated(orbitAngles[bullet] + PI / 2)

func onChildParried(groupID: int, childPos: Vector2) -> void:
	var bulletGroup = groups.get(groupID, [])
	
	# check if the parried bullet is the lead
	if bulletGroup.size() > 0 && is_instance_valid(bulletGroup[0]) && bulletGroup[0].parriedBullet:
		var leadPos = bulletGroup[0].global_position
		for i in range(1, bulletGroup.size()):
			var bullet = bulletGroup[i]
			if is_instance_valid(bullet) && !bullet.parriedBullet && bullet.timeToStart && bullet.get_parent() == self:
				bullet.reparent.call_deferred(get_parent())
			
			if !bullet.parriedBullet:
				releaseBullet(bullet, leadPos)
	
	# reparent any already-released orbiting bullets before base class checks
	for i in range(1, bulletGroup.size()):
		var bullet = bulletGroup[i]
		if !is_instance_valid(bullet):
			continue
		if !bullet.parriedBullet && bullet.timeToStart:
			bullet.reparent.call_deferred(get_parent())
	
	super.onChildParried(groupID, childPos)

func onBulletDestroyed(destroyedBullet: Bullet) -> void:
	super.onBulletDestroyed(destroyedBullet)
	
	for id in groups:
		var bulletGroup = groups[id]
		if bulletGroup.size() > 0 && bulletGroup[0] == destroyedBullet:
			var leadPos = destroyedBullet.global_position
			for i in range(1, bulletGroup.size()):
				var bullet = bulletGroup[i]
				if !is_instance_valid(bullet) || bullet.parriedBullet:
					continue
				
				# only affect bullets that are still children of the pattern
				if bullet.get_parent() != self:
					continue
				
				if !bullet.parriedBullet:
					releaseBullet(bullet, leadPos)
				bullet.reparent.call_deferred(get_parent())
			break

func onAllParried(groupID: int, childPos: Vector2) -> void:
	var bulletGroup = groups.get(groupID, [])
	var leadPos = bulletGroup[0].global_position if is_instance_valid(bulletGroup[0]) else Vector2.ZERO
	for i in range(1, bulletGroup.size()):
		var bullet = bulletGroup[i]
		if is_instance_valid(bullet) && !bullet.parriedBullet:
			releaseBullet(bullet, leadPos)
	super.onAllParried(groupID, childPos)

func releaseBullet(bullet: Bullet, leadPos: Vector2) -> void:
	bullet.isOrbiting = false
	bullet.timeToStart = true
	if "shrapnelCount" in bullet:
		bullet.destroyTimer.paused = false
	if "target" in bullet:
		bullet.setTarget(get_tree().get_first_node_in_group("Player"))
	else:
		bullet.moveDir = (bullet.global_position - leadPos).normalized()
