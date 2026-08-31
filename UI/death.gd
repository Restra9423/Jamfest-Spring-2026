extends Control

@export var scoreDisplay : Label
var tips = [
	"Getting hit or missing a parry\nboth reset your combo.",
	"Your combo counter gives\nyou a score multiplier!",
	"Every 10,000 points\ngives you 1 life back!",
	"Parrying an entire bullet\nformation gives you bonus points!"
	]

func _ready() -> void:
	$VBoxContainer/HBoxContainer/VBoxContainer/Restart.grab_focus()
	scoreDisplay.text = str(ScoreCounter.currentScore)
	%Tips.text = "\n" + tips.pick_random()
	AudioController.playSFX(AudioController.deathSound)
	AudioController.playMusic(AudioController.deathBGM)
	
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
	#mouseInput = mouseInput.move_toward(Vector2.ZERO, 20.0 * _delta)

func _on_any_button_focused() -> void:
	AudioController.playSFX(AudioController.mouseOverSound)

func _on_restart_pressed() -> void:
	ScoreCounter.resetScore()
	AudioController.playSFX(AudioController.clickSound)
	get_tree().change_scene_to_file("res://Levels/world_scene.tscn")

func _on_main_menu_pressed() -> void:
	AudioController.playSFX(AudioController.clickSound)
	get_tree().change_scene_to_file("res://UI/title.tscn")

func _on_quit_pressed() -> void:
	AudioController.playSFX(AudioController.clickSound)
	get_tree().quit()
