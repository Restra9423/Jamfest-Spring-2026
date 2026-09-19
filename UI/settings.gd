extends Control

@export var sfx: AudioStreamPlayer
@onready var musicSlider : HSlider = %musicSlider
@onready var sfxSlider : HSlider = %sfxSlider
@onready var musicDisplay : Label = %musicDisplay
@onready var sfxDisplay : Label = %sfxDisplay
@onready var seedInput : LineEdit = $VBoxContainer/HBoxContainer2/seedInput

var input = 0.0
var timePressed = 0.0
var carry := 0.0
var isFiltering : bool = false

var mouseInput = Vector2.ZERO
var aimInput = Vector2.ZERO

func _ready() -> void:
	AudioController.playMusic(AudioController.gameBGM)
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	musicSlider.value = AudioController.musicSliderValue
	sfxSlider.value = AudioController.sfxSliderValue
	
	if (SeedManager.playerSeedInput == true):
		seedInput.text = str(SeedManager.random.seed)
	
	for button in get_tree().get_nodes_in_group("UI Buttons"):
		button.mouse_entered.connect(_on_any_button_focused)
		button.focus_entered.connect(_on_any_button_focused)
	
	var musicDB = AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Music"))
	if musicDB <= -5.0:
		musicSlider.value = remap(musicDB, -15.0, -5.0, 0.1, 50.0)
	else:
		musicSlider.value = remap(musicDB, -5.0, 10.0, 50.0, 100.0)

	var sfxDB = AudioServer.get_bus_volume_db(AudioServer.get_bus_index("SFX"))
	if sfxDB <= 2.5:
		sfxSlider.value = remap(sfxDB, -15.0, 2.5, 0.1, 50.0)
	else:
		sfxSlider.value = remap(sfxDB, 2.5, 10.0, 50.0, 100.0)
	
	musicSlider.grab_focus()

func _process(_delta) -> void:
	musicDisplay.text = str(snappedf(db_to_linear(remap(musicSlider.value, 0.0, 100.0, -15.0, 10.0)), 0.01))
	sfxDisplay.text = str(snappedf(db_to_linear(remap(sfxSlider.value, 0.0, 100.0, -15.0, 10.0)), 0.01))
	
	input = Input.get_axis("ui_left", "ui_right")
	var speedMultiplier = input * 1
	if input == 0:
		musicSlider.editable = true
		sfxSlider.editable = true
		timePressed = 0.0
		carry = 0.0
	else:
		musicSlider.editable = false
		sfxSlider.editable = false
		timePressed += _delta
		speedMultiplier *= (1 + pow(timePressed + 0.5, 2.25))
		var slider = get_viewport().gui_get_focus_owner()
		if slider is HSlider:
			carry += speedMultiplier * _delta * 16
			var frameSteps = int(carry / slider.step) * slider.step
			if int(carry / slider.step) != 0:
				slider.value += frameSteps
				carry -= frameSteps
	
	if Input.is_action_just_pressed("Back"):
		AudioController.playSFX(AudioController.clickSound)
		get_tree().change_scene_to_file("res://UI/title.tscn")

func _on_any_button_focused() -> void:
	AudioController.playSFX(AudioController.mouseOverSound)

func _on_music_slider_value_changed(value: float) -> void:
	AudioController.musicSliderValue = value
	if value == 0.0:
		AudioController.setMusicVolume(-80.0)
	elif value <= 50.0:
		var db = remap(value, 0.1, 50.0, -15.0, -5.0)
		AudioController.setMusicVolume(db)
	else:
		var db = remap(value, 50.0, 100.0, -5.0, 10.0)
		AudioController.setMusicVolume(db)

func _on_sfx_slider_value_changed(value: float) -> void:
	AudioController.sfxSliderValue = value
	if value == 0.0:
		AudioController.setSFXVolume(-80.0)
	elif value <= 50.0:
		var db = remap(value, 0.1, 50.0, -15.0, 2.5)
		AudioController.setSFXVolume(db)
	else:
		var db = remap(value, 50.0, 100.0, 2.5, 10.0)
		AudioController.setSFXVolume(db)

func _on_seed_input_text_changed(new_text: String) -> void:
	if isFiltering:
		return
	var valid = ""
	for c in new_text:
		if c.is_valid_int():
			valid += c
	if valid != new_text:
		isFiltering = true
		seedInput.text = valid
		seedInput.caret_column = valid.length()
		isFiltering = false

func _on_seed_input_text_submitted(new_text: String) -> void:
	if (new_text == ""):
		SeedManager.setSeed()
	elif SeedManager.validateSeed(new_text):
		SeedManager.setSeed(int(new_text))
	$VBoxContainer/Exit.grab_focus()

func _on_exit_pressed() -> void:
	AudioController.playSFX(AudioController.clickSound)
	get_tree().change_scene_to_file("res://UI/title.tscn")

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		mouseInput = event.get_relative()
