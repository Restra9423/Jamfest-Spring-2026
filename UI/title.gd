extends Control


func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	$VBoxContainer/Start.grab_focus()
	AudioController.playMusic(AudioController.gameBGM)

func _on_start_pressed() -> void:
	AudioController.playSFX(AudioController.clickSound)
	get_tree().change_scene_to_file("res://Levels/world_scene.tscn")

func _on_settings_pressed() -> void:
	AudioController.playSFX(AudioController.clickSound)
	get_tree().change_scene_to_file("res://UI/settings.tscn")

func _on_credits_pressed() -> void:
	AudioController.playSFX(AudioController.clickSound)
	get_tree().change_scene_to_file("res://UI/credits.tscn")

func _on_quit_pressed() -> void:
	AudioController.playSFX(AudioController.clickSound)
	get_tree().quit()
