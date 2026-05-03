extends Node2D

@onready var waveTimer : Timer = $WaveTimer
var totalWaves : float = 0.0

# Create an array of references to each existing bullet pattern
@export var patternList : Array[PackedScene]

func _on_ready() -> void:
	waveTimer.wait_time = 0.0

# Randomly call a pattern from that array, repeat infinitely
# Increase bullet speed and decrease time between waves over time
func _on_wave_timer_timeout() -> void:
	if totalWaves < 1:
		waveTimer.wait_time = 3.0
	totalWaves += 1
	var currentWave = patternList[randi_range(0, patternList.size()-1)].instantiate()
	add_child(currentWave)
	currentWave.totalWaves = totalWaves
	waveTimer.wait_time *= 0.99
