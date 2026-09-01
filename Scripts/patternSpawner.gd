extends Node2D

@onready var waveTimer : Timer = $WaveTimer
var totalWaves : float = 0.0
var currentDifficulty : int = 0

# Create difficulty-based arrays of references to each existing bullet pattern
@export var easyPatterns : Array[PackedScene]
@export var mediumPatterns : Array[PackedScene]
@export var hardPatterns : Array[PackedScene]
@export var superHardPatterns : Array[PackedScene]
@export var testPatterns : Array[PackedScene]

var patternsByDifficulty : Dictionary = {}
var cooldownIndices : Dictionary = {}

func _ready() -> void:
	waveTimer.wait_time = 0.0
	patternsByDifficulty = {
		0: easyPatterns,
		1: mediumPatterns,
		2: hardPatterns,
		3: superHardPatterns,
		4: testPatterns
	}

# Randomly call a pattern from that array, repeat infinitely
# Decrease time between waves over time
func _on_wave_timer_timeout() -> void:
	if totalWaves < 1:
		waveTimer.wait_time = 3.0
	
	# increase wave count
	totalWaves += 1
	currentDifficulty = 4
	
	# increase difficulty when threshold is met
	var targetDifficulty = mini(ScoreCounter.currentScore / 20000, 3)
	if targetDifficulty > currentDifficulty:
		currentDifficulty += 1
		totalWaves = 1
		waveTimer.wait_time = 3.0 - (0.08 * currentDifficulty)
	var currentList = patternsByDifficulty[currentDifficulty]
	
	# get all available indices that aren't on cooldown
	var availableIndices : Array = []
	for i in currentList.size():
		if i not in cooldownIndices:
			availableIndices.append(i)
	
	# fall back to all indices if everything is on cooldown
	if availableIndices.is_empty():
		availableIndices = range(currentList.size())
	
	# spawn a pattern
	var chosenIndex = availableIndices[randi_range(0, availableIndices.size() - 1)]
	var currentWave = currentList[chosenIndex].instantiate()
	currentWave.totalWaves = totalWaves
	add_child(currentWave)
	
	# create cooldown timer if pattern has a spawnCooldown
	if "spawnCooldown" in currentWave && currentWave.spawnCooldown > 0.0:
		var cooldownTimer = Timer.new()
		add_child(cooldownTimer)
		cooldownTimer.wait_time = currentWave.spawnCooldown
		cooldownTimer.one_shot = true
		cooldownIndices[chosenIndex] = cooldownTimer
		cooldownTimer.timeout.connect(func():
			cooldownIndices.erase(chosenIndex)
			cooldownTimer.queue_free()
		)
		cooldownTimer.start()
	
	waveTimer.wait_time *= 0.995
