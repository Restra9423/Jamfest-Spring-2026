extends Node2D

@export var levelProgressBar : Control

func _ready() -> void:
	ScoreCounter.resetScore()
	AudioController.playMusic(AudioController.gameBGM)
	
	if levelProgressBar != null:
		ScoreCounter.setLevel(1)
		# ScoreCounter.setLevel(0)
		levelProgressBar.updateLevel()
