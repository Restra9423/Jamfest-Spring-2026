extends Control

@export var sfx: AudioStreamPlayer
var click_sound = preload("res://Sound/SFX/UISelect8Bit_SFX.wav")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_back_button_pressed() -> void:
	sfx.stream = click_sound
	sfx.play()
	get_tree().change_scene_to_file("res://UI/title.tscn")
