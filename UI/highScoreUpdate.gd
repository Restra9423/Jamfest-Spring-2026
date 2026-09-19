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

@onready var playerNameInput : LineEdit = $VBoxContainer/NameInput
@onready var continueButton : Button = $VBoxContainer/continueButton

var newHighScorePos = null
var newHighScorePosFound : bool = false
var colors = [Color.ORANGE_RED, Color.DARK_ORANGE, Color.GREEN_YELLOW, Color.LIGHT_SEA_GREEN, Color.CORNFLOWER_BLUE]
var colorIndex : int = 0

func _ready() -> void:
	continueButton.disabled = true
	set_process_input(false)
	set_process_unhandled_input(false)
	
	for i in HighScores.toBeSaved:
		highScoreDisplays[i].playerName.text = HighScores.toBeSaved[i].playerName
		highScoreDisplays[i].score.text = str(HighScores.toBeSaved[i].score)
	
	var newHighScore = ScoreCounter.currentScore
	var keys = highScoreDisplays.keys()
	var carryName = ""
	var carryScore = newHighScore
	
	for key in keys:
		if newHighScore > int(highScoreDisplays[key].score.text):
			if !newHighScorePos:
				newHighScorePos = key
				newHighScorePosFound = true
			
			var tempName = highScoreDisplays[key].playerName.text
			var tempScore = highScoreDisplays[key].score.text
			
			highScoreDisplays[key].playerName.text = carryName
			highScoreDisplays[key].score.text = str(carryScore)
			
			carryName = tempName
			carryScore = tempScore
	
	var tween = create_tween().set_loops()
	tween.tween_callback(func():
		highScoreDisplays[newHighScorePos].playerName.modulate = colors[colorIndex]
		highScoreDisplays[newHighScorePos].score.modulate = colors[colorIndex]
		colorIndex = (colorIndex + 1) % colors.size()
	).set_delay(0.2)
	
	await get_tree().create_timer(0.3).timeout
	set_process_input(true)
	set_process_unhandled_input(true)
	playerNameInput.grab_focus()
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _on_line_edit_text_changed(new_text: String) -> void:
	highScoreDisplays[newHighScorePos].playerName.text = playerNameInput.text

func _on_line_edit_text_submitted(new_text: String) -> void:
	highScoreDisplays[newHighScorePos].playerName.text = playerNameInput.text
	for key in highScoreDisplays:
		HighScores.toBeSaved[key].playerName = highScoreDisplays[key].playerName.text
		HighScores.toBeSaved[key].score = int(highScoreDisplays[key].score.text)
	HighScores._save()
	continueButton.disabled = false
	continueButton.grab_focus()

func _on_continue_button_pressed() -> void:
	get_tree().change_scene_to_file("res://UI/death.tscn")
