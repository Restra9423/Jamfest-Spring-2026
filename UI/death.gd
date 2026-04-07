extends Control

@export var sfx: AudioStreamPlayer
@export var scoreDisplay : Label
var click_sound = preload("res://Sound/SFX/UISelect8Bit_SFX.wav")
var death_sound = preload("res://Sound/SFX/ExplosionDeath8Bit_SFX.wav")

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	scoreDisplay.text = str(ScoreCounter.currentScore)
	sfx.stream = death_sound
	sfx.play()

func _on_restart_pressed() -> void:
	ScoreCounter.currentScore = 0
	sfx.stream = click_sound
	sfx.play()
	get_tree().change_scene_to_file("res://Levels/world_scene.tscn")

func _on_main_menu_pressed() -> void:
	sfx.stream = click_sound
	sfx.play()
	get_tree().change_scene_to_file("res://UI/title.tscn")

func _on_quit_pressed() -> void:
	sfx.stream = click_sound
	sfx.play()
	get_tree().quit()
