extends Control

@export var scoreDisplay : Label

func _ready() -> void:
	scoreDisplay.text = str(ScoreCounter.currentScore)
	AudioController.playSFX(AudioController.deathSound)
	AudioController.playMusic(AudioController.deathBGM)
	await get_tree().create_timer(0.5).timeout
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _on_restart_pressed() -> void:
	ScoreCounter.currentScore = 0
	AudioController.playSFX(AudioController.clickSound)
	get_tree().change_scene_to_file("res://Levels/world_scene.tscn")

func _on_main_menu_pressed() -> void:
	AudioController.playSFX(AudioController.clickSound)
	get_tree().change_scene_to_file("res://UI/title.tscn")

func _on_quit_pressed() -> void:
	AudioController.playSFX(AudioController.clickSound)
	get_tree().quit()
