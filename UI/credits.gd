extends Control

func _ready() -> void:
	AudioController.playMusic(AudioController.gameBGM)

func _on_back_button_pressed() -> void:
	AudioController.playSFX(AudioController.clickSound)
	get_tree().change_scene_to_file("res://UI/title.tscn")
