extends Control

@export var sfx: AudioStreamPlayer
@onready var aimSlider : HSlider = $VBoxContainer/Sensitivity/aimSlider
var click_sound = preload("res://Sound/SFX/UISelect8Bit_SFX.wav")
var death_sound = preload("res://Sound/SFX/ExplosionDeath8Bit_SFX.wav")

func _ready() -> void:
	AudioController.playMusic(AudioController.gameBGM)
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	aimSlider.value = SettingsManager.mouseSensitivity

func _on_h_slider_drag_ended(value_changed: bool) -> void:
	SettingsManager.setMouseSensitivity(aimSlider.value)

func _on_exit_pressed() -> void:
	AudioController.playSFX(AudioController.clickSound)
	get_tree().change_scene_to_file("res://UI/title.tscn")
