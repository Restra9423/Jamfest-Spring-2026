extends Node2D

func _ready() -> void:
	ScoreCounter.resetScore()
	AudioController.playMusic(AudioController.gameBGM)
