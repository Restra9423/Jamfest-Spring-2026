extends Control

@onready var highScoreDisplays : Dictionary = {
	"FirstPlace": {
		"playerName": $VBoxContainer/FirstPlace/PlayerName,
		"score": $VBoxContainer/FirstPlace/Score
	},
	"SecondPlace": {
		"playerName": $VBoxContainer/SecondPlace/PlayerName,
		"score": $VBoxContainer/SecondPlace/Score
	},
	"ThirdPlace": {
		"playerName": $VBoxContainer/ThirdPlace/PlayerName,
		"score": $VBoxContainer/ThirdPlace/Score
	},
	"FourthPlace": {
		"playerName": $VBoxContainer/FourthPlace/PlayerName,
		"score": $VBoxContainer/FourthPlace/Score
	},
	"FifthPlace": {
		"playerName": $VBoxContainer/FifthPlace/PlayerName,
		"score": $VBoxContainer/FifthPlace/Score
	}
}

@onready var scoreClearPopUp = $ScoreClearPopUp

func _ready() -> void:
	$VBoxContainer/backButton.grab_focus()
	
	scoreClearPopUp.visible = false
	scoreClearPopUp.yesButtonPressed.connect(_on_yes_button_pressed)
	scoreClearPopUp.noButtonPressed.connect(_on_no_button_pressed)
	setScores()

func setScores() -> void:
	for i in HighScores.toBeSaved:
		highScoreDisplays[i].playerName.text = HighScores.toBeSaved[i].playerName
		highScoreDisplays[i].score.text = str(HighScores.toBeSaved[i].score)

func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file("res://UI/title.tscn")

func _on_clear_button_pressed() -> void:
	scoreClearPopUp.visible = true
	scoreClearPopUp.focusNoButton()

func _on_yes_button_pressed() -> void:
	HighScores._clear()
	setScores()
	scoreClearPopUp.visible = false
	$VBoxContainer/backButton.grab_focus()

func _on_no_button_pressed() -> void:
	scoreClearPopUp.visible = false
	$VBoxContainer/backButton.grab_focus()
