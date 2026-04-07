extends Node

var currentScore : int = 0

func incrementScore(points: int):
	currentScore += points

func resetScore() -> void:
	currentScore = 0
