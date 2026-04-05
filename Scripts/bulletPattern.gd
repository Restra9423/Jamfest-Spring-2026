extends Node2D


func _process(delta: float) -> void:
	if (get_child_count() == 0):
		print("i am dead lol")
		queue_free()
