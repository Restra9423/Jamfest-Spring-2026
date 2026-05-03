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
	musicSlider.value = AudioController.musicSliderValue
	sfxSlider.value = AudioController.sfxSliderValue
	
	for button in get_tree().get_nodes_in_group("UI Buttons"):
		button.mouse_entered.connect(_on_any_button_focused)
		button.focus_entered.connect(_on_any_button_focused)
	
	var musicDB = AudioController.music.volume_db
	if musicDB <= -5.0:
		musicSlider.value = remap(musicDB, -15.0, -5.0, 0.1, 50.0)
	else:
		musicSlider.value = remap(musicDB, -5.0, 10.0, 50.0, 100.0)

	var sfxDB = AudioController.sfx.volume_db
	if sfxDB <= 2.5:
		sfxSlider.value = remap(sfxDB, -15.0, 2.5, 0.1, 50.0)
	else:
		sfxSlider.value = remap(sfxDB, 2.5, 10.0, 50.0, 100.0)

func _process(_delta) -> void:
	aimDisplay.text = str(aimSlider.value)
	musicDisplay.text = str(snappedf(db_to_linear(remap(musicSlider.value, 0.0, 100.0, -15.0, 10.0)), 0.01))
	sfxDisplay.text = str(snappedf(db_to_linear(remap(sfxSlider.value, 0.0, 100.0, -15.0, 10.0)), 0.01))

func _on_any_button_focused() -> void:
	AudioController.playSFX(AudioController.mouseOverSound)

func _on_h_slider_drag_ended(_value_changed: bool) -> void:
	SettingsManager.setMouseSensitivity(5.0 - (aimSlider.value / 10))

func _on_music_slider_value_changed(value: float) -> void:
	AudioController.musicSliderValue = value
	if value == 0.0:
		AudioController.setVolume(AudioController.music, -80.0)
	elif value <= 50.0:
		var db = remap(value, 0.1, 50.0, -15.0, -5.0)
		AudioController.setVolume(AudioController.music, db)
	else:
		var db = remap(value, 50.0, 100.0, -5.0, 10.0)
		AudioController.setVolume(AudioController.music, db)

func _on_sfx_slider_value_changed(value: float) -> void:
	AudioController.sfxSliderValue = value
	if value == 0.0:
		AudioController.setVolume(AudioController.sfx, -80.0)
	elif value <= 50.0:
		var db = remap(value, 0.1, 50.0, -15.0, 2.5)
		AudioController.setVolume(AudioController.sfx, db)
	else:
		var db = remap(value, 50.0, 100.0, 2.5, 10.0)
		AudioController.setVolume(AudioController.sfx, db)


func _on_exit_pressed() -> void:
	AudioController.playSFX(AudioController.clickSound)
	get_tree().change_scene_to_file("res://UI/title.tscn")
