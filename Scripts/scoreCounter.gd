extends Node

var currentScore : int = 0
var combo : float = 0.0

func incrementScore(points: int) -> void:
	currentScore += int(points * (1 + combo/10))

func incrementCombo() -> void:
	combo += 1.0

func resetCombo() -> void:
	combo = 0.0

func resetScore() -> void:
	currentScore = 0
