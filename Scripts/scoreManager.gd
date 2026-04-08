extends Control
class_name ScoreManager

@export var scoreDisplay : Label
@export var comboDisplay : Label

static var instance: ScoreManager

func _init() -> void:
	instance = self

func updateScore():
	scoreDisplay.text = str(ScoreCounter.currentScore)

func updateCombo():
	comboDisplay.text = str(int(ScoreCounter.combo), "x")
