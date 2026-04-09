extends Control

@export var sfx: AudioStreamPlayer
@onready var aimSlider : HSlider = %aimSlider
@onready var musicSlider : HSlider = %musicSlider
@onready var sfxSlider : HSlider = %sfxSlider
@onready var aimDisplay : Label = %aimDisplay
@onready var musicDisplay : Label = %musicDisplay
@onready var sfxDisplay : Label = %sfxDisplay

func _ready() -> void:
	AudioController.playMusic(AudioController.gameBGM)
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	aimSlider.value = (5.0 - (SettingsManager.mouseSensitivity / 10))
	if (AudioController.music.volume_db == -5.0 && AudioController.sfx.volume_db == 2.5):
		musicSlider.value = 50.0
		sfxSlider.value = 50.0
	else:
		musicSlider.value = AudioController.music.volume_db
		sfxSlider.value = AudioController.music.volume_db

func _process(_delta) -> void:
	aimDisplay.text = str(aimSlider.value)
	musicDisplay.text = str(musicSlider.value)
	sfxDisplay.text = str(sfxSlider.value)

func _on_h_slider_drag_ended(_value_changed: bool) -> void:
	SettingsManager.setMouseSensitivity(5.0 - (aimSlider.value / 10))

func _on_music_slider_drag_ended(_value_changed: bool) -> void:
	if (musicSlider.value == 0.0):
		AudioController.setVolume(AudioController.music, -80.0)
	elif musicSlider.value <= 50.0:
		var db = remap(musicSlider.value, 0.1, 50.0, -15.0, -5.0)
		AudioController.setVolume(AudioController.music, db)
	else:
		var db = remap(musicSlider.value, 50.0, 100.0, -5.0, 10.0)
		AudioController.setVolume(AudioController.music, db)

func _on_sfx_slider_drag_ended(_value_changed: bool) -> void:
	if (sfxSlider.value == 0.0):
		AudioController.setVolume(AudioController.sfx, -80.0)
	elif musicSlider.value <= 50.0:
		var db = remap(musicSlider.value, 0.1, 50.0, -15.0, 2.5)
		AudioController.setVolume(AudioController.music, db)
	else:
		var db = remap(musicSlider.value, 50.0, 100.0, 2.5, 10.0)
		AudioController.setVolume(AudioController.music, db)

func _on_exit_pressed() -> void:
	AudioController.playSFX(AudioController.clickSound)
	get_tree().change_scene_to_file("res://UI/title.tscn")
