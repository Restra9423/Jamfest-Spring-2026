extends Node2D


func _process(delta: float) -> void:
	if (get_child_count() == 0):
		queue_free()
