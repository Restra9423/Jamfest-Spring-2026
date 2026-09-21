extends Node

var currentScore : int = 0
var currentLevel : int = 0
var scoreBeforeNewPoints : int = 0
var combo : float = 0.0
var comboMaxed : bool = false

func incrementScore(points: int) -> void:
	currentScore += int(points * (1 + combo/10))

func incrementCombo() -> void:
	if combo < 40.0:
		combo += 1.0
	elif !comboMaxed:
		maxCombo()

func resetCombo() -> void:
	combo = 0.0
	comboMaxed = false

func resetScore() -> void:
	currentScore = 0
	scoreBeforeNewPoints = 0

func setLevel(newLevel : int = -1) -> void:
	if newLevel == -1:
		currentLevel += 1
	else:
		currentLevel = newLevel

func maxCombo() -> void:
	comboMaxed = true

func breakMaxCombo() -> void:
	combo = 20.0
	comboMaxed = false
