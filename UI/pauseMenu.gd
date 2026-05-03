extends Control

@onready var timer = $Timer
var mouseInput = Vector2.ZERO
var aimInput = Vector2.ZERO

func _ready() -> void:
	for button in get_tree().get_nodes_in_group("UI Buttons"):
		button.mouse_entered.connect(_on_any_button_focused)
		button.focus_entered.connect(_on_any_button_focused)

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("Back") && timer.time_left == 0:
		if !get_tree().paused:
			get_tree().paused = true
			visible = true
			AudioController.playSFX(AudioController.clickSound)
			$VBoxContainer/Resume.grab_focus()
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			AudioController.playSFX(AudioController.clickSound)
			get_tree().paused = false
			visible = false
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			timer.start()
#
	#aimInput = Vector2(Input.get_axis("ui_left", "ui_right"), Input.get_axis("ui_up", "ui_down"))
	#if aimInput != Vector2.ZERO:
		#Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED_HIDDEN)
	#elif mouseInput.length() > 0:
		#Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	#mouseInput = mouseInput.move_toward(Vector2.ZERO, 20.0 * _delta)

func _on_any_button_focused() -> void:
	AudioController.playSFX(AudioController.mouseOverSound)

func _on_resume_pressed() -> void:
	AudioController.playSFX(AudioController.clickSound)
	get_tree().paused = false
	visible = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED_HIDDEN)
	timer.start()

func _on_restart_pressed() -> void:
	AudioController.playSFX(AudioController.clickSound)
	get_tree().paused = false
	get_tree().reload_current_scene()

func _on_main_menu_pressed() -> void:
	AudioController.playSFX(AudioController.clickSound)
	get_tree().paused = false
	get_tree().change_scene_to_file("res://UI/title.tscn")

func _on_quit_pressed() -> void:
	AudioController.playSFX(AudioController.clickSound)
	get_tree().quit()
	
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		mouseInput = event.get_relative()
