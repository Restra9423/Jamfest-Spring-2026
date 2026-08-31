extends Control

var mouseInput = Vector2.ZERO
var aimInput = Vector2.ZERO

func _ready() -> void:
	$VBoxContainer/HBoxContainer2/backButton.grab_focus()
	
	AudioController.playMusic(AudioController.gameBGM)
	for button in get_tree().get_nodes_in_group("UI Buttons"):
		button.mouse_entered.connect(_on_any_button_focused)
		button.focus_entered.connect(_on_any_button_focused)
	
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("Back"):
		AudioController.playSFX(AudioController.clickSound)
		get_tree().change_scene_to_file("res://UI/title.tscn")
	#
	#aimInput = Vector2(Input.get_axis("ui_left", "ui_right"), Input.get_axis("ui_up", "ui_down"))
	#if aimInput != Vector2.ZERO:
		#Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED_HIDDEN)
	#elif mouseInput.length() > 0:
		#Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	#mouseInput = Vector2.ZERO

func _on_any_button_focused() -> void:
	AudioController.playSFX(AudioController.mouseOverSound)

func _on_back_button_pressed() -> void:
	AudioController.playSFX(AudioController.clickSound)
	get_tree().change_scene_to_file("res://UI/title.tscn")

func _on_next_button_pressed() -> void:
	AudioController.playSFX(AudioController.clickSound)
	get_tree().change_scene_to_file("res://UI/tutorial_2.tscn")

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		mouseInput = event.get_relative()
