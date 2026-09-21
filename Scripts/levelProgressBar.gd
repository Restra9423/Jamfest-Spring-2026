extends Control

@onready var progressBar : ProgressBar = $VBoxContainer/ProgressBar
@onready var levelLabel : Label = $VBoxContainer/Label
var levelProgressPercent : float = 0.0
var updateTracker : int = 0

var levelUpThresholds : Dictionary = {
	1: 500,
	2: 5000,
	3: 10000,
	4: 20000,
	5: 30000,
	6: 40000,
	7: 50000,
	8: 60000
}

func updateProgress():
	if (updateTracker != ScoreCounter.currentScore):
		var initialScore = levelUpThresholds[ScoreCounter.currentLevel - 1] if ScoreCounter.currentLevel > 1 && levelUpThresholds.has(ScoreCounter.currentLevel - 1) else 0
		var threshold = levelUpThresholds[ScoreCounter.currentLevel] if levelUpThresholds.has(ScoreCounter.currentLevel) else 0
		
		levelProgressPercent = float(ScoreCounter.currentScore - initialScore) / float(threshold - initialScore) * 100.0
		progressBar.value = levelProgressPercent
		updateTracker = ScoreCounter.currentScore
		
		if levelUp():
			updateLevel()

func levelUp() -> bool:
	if progressBar.value >= 100.0 && levelUpThresholds.has(ScoreCounter.currentLevel):
		return true
	return false

func updateLevel():
	if levelUp():
		ScoreCounter.setLevel()
	levelLabel.text = "Level " + str(ScoreCounter.currentLevel)
	updateTracker = -1
	updateProgress()
