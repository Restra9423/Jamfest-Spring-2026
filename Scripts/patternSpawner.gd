extends Node2D

@onready var waveTimer : Timer = $WaveTimer
var totalWaves : float = 0.0
var currentDifficulty : int = 0

# Create difficulty-based arrays of references to each existing bullet pattern
@export var easyPatterns : Array[PackedScene]
@export var mediumPatterns : Array[PackedScene]
@export var hardPatterns : Array[PackedScene]

var patternsByDifficulty : Dictionary = {}

func _ready() -> void:
	waveTimer.wait_time = 0.0
	patternsByDifficulty = {
		0: easyPatterns,
		1: mediumPatterns,
		2: hardPatterns
	}

# Randomly call a pattern from that array, repeat infinitely
# Decrease time between waves over time
func _on_wave_timer_timeout() -> void:
	if totalWaves < 1:
		waveTimer.wait_time = 3.0
	totalWaves += 1
	var targetDifficulty = mini(ScoreCounter.currentScore / 20000, 2)
	if targetDifficulty > currentDifficulty:
		currentDifficulty += 1
		totalWaves = 1
		waveTimer.wait_time = 3.0 - (0.1 * currentDifficulty)
	var currentList = patternsByDifficulty[currentDifficulty]
	var currentWave = currentList[randi_range(0, currentList.size() - 1)].instantiate()
	add_child(currentWave)
	currentWave.totalWaves = totalWaves
	waveTimer.wait_time *= 0.99
