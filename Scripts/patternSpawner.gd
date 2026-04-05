extends Node2D

@onready var waveTimer : Timer = $WaveTimer
var totalWaves : float = 0.0
var parryCirclePattern1 = preload("res://Prefabs/Bullet Patterns/ParryCirclePattern1.tscn")
var unparryCirclePattern1 = preload("res://Prefabs/Bullet Patterns/UnparryCirclePattern1.tscn")
var parrySpearPattern = preload("res://Prefabs/Bullet Patterns/ParrySpearPattern.tscn")
var unparrySpearPattern = preload("res://Prefabs/Bullet Patterns/UnparrySpearPattern.tscn")
var vPattern = preload("res://Prefabs/Bullet Patterns/VPattern.tscn")
var linePattern = preload("res://Prefabs/Bullet Patterns/LinePattern.tscn")
var wavePattern = preload("res://Prefabs/Bullet Patterns/WavePattern.tscn")

# Create an array of references to each existing bullet pattern
var patternList = [parryCirclePattern1, unparryCirclePattern1, parrySpearPattern, unparrySpearPattern, vPattern, linePattern, wavePattern]

# Randomly call a pattern from that array, repeat infinitely
# Increase bullet speed and decrease time between waves over time
func _on_wave_timer_timeout() -> void:
	totalWaves += 1
	var currentWave = patternList[randi_range(0, patternList.size()-1)].instantiate()
	add_child(currentWave)
	waveTimer.wait_time *= 0.99
	
	for child in currentWave.get_child_count():
		if totalWaves > 0:
			currentWave.get_child(child).speed *= (1.01 * totalWaves)
