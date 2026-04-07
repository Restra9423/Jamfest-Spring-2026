extends Control

@export var scoreDisplay : Label

func updateScore():
	scoreDisplay.text = str(ScoreCounter.currentScore)
