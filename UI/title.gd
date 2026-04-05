extends Control

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _on_start_pressed() -> void:
	get_tree().change_scene_to_file("res://Levels/world_scene.tscn")


func _on_credits_pressed() -> void:
	get_tree().change_scene_to_file("res://UI/credits.tscn")


func _on_quit_pressed() -> void:
	get_tree().quit()
