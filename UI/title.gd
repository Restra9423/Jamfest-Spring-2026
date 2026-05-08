extends Control

var mouseInput = Vector2.ZERO
var aimInput = Vector2.ZERO

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	$VBoxContainer/Start.grab_focus()
	AudioController.playMusic(AudioController.gameBGM)
	
	for button in get_tree().get_nodes_in_group("UI Buttons"):
		button.mouse_entered.connect(_on_any_button_focused)
		button.focus_entered.connect(_on_any_button_focused)
		
func _process(_delta: float) -> void:
	#if Input.is_action_just_pressed("Back"):
		#AudioController.playSFX(AudioController.clickSound)
		#get_tree().quit()
	pass
	#aimInput = Vector2(Input.get_axis("ui_left", "ui_right"), Input.get_axis("ui_up", "ui_down"))
	#if aimInput != Vector2.ZERO:
		#Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED_HIDDEN)
	#if mouseInput.length() > 0:
		#Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	#mouseInput = mouseInput.move_toward(Vector2.ZERO, 5.0 * _delta)

func _on_any_button_focused() -> void:
	AudioController.playSFX(AudioController.mouseOverSound)

func _on_start_pressed() -> void:
	ScoreCounter.resetScore()
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

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		mouseInput = event.get_relative()
