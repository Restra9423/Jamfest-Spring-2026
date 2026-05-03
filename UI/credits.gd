extends Control

func _ready() -> void:
	AudioController.playMusic(AudioController.gameBGM)
	
	for button in get_tree().get_nodes_in_group("UI Buttons"):
		button.mouse_entered.connect(_on_any_button_focused)
		button.focus_entered.connect(_on_any_button_focused)

func _process(_delta: float) -> void:
	if(Input.is_action_just_pressed("Back")):
		AudioController.playSFX(AudioController.clickSound)
		get_tree().change_scene_to_file("res://UI/title.tscn")

func _on_any_button_focused() -> void:
	AudioController.playSFX(AudioController.mouseOverSound)

func _on_back_button_pressed() -> void:
	AudioController.playSFX(AudioController.clickSound)
	get_tree().change_scene_to_file("res://UI/title.tscn")
