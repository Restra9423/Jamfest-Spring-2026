extends Control

@export var sfx: AudioStreamPlayer
var click_sound = preload("res://Sound/SFX/UISelect8Bit_SFX.wav")

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	pass

func _on_back_button_pressed() -> void:
	#sfx.stream = click_sound
	#sfx.play()
	get_tree().change_scene_to_file("res://UI/title.tscn")
