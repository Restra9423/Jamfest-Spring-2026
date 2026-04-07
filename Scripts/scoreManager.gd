extends Control

@export var scoreDisplay : Label
@export var comboDisplay : Label

func updateScore():
	scoreDisplay.text = str(ScoreCounter.currentScore)

func updateCombo():
	comboDisplay.text = str(int(ScoreCounter.combo), "x")
