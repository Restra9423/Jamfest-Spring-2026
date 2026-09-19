extends Control

signal yesButtonPressed
signal noButtonPressed

@onready var yesButton = $VBoxContainer/HBoxContainer/YesButton
@onready var noButton = $VBoxContainer/HBoxContainer/NoButton

func focusYesButton() -> void:
	yesButton.grab_focus()

func focusNoButton() -> void:
	noButton.grab_focus()

func _on_yes_button_pressed() -> void:
	yesButtonPressed.emit()

func _on_no_button_pressed() -> void:
	noButtonPressed.emit()
