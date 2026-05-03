extends Node

@onready var damageBounds : Area2D = $DamageBounds

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	for body in damageBounds.get_overlapping_bodies():
		if body.is_in_group("Player"):
			body.hurt()
