extends Node2D

@onready var waveTimer : Timer = $WaveTimer
var totalWaves : float = 0.0
var currentList
var patternRng : RandomNumberGenerator

@export var levelProgressBar : Control
@export var testPatterns : Array[PackedScene]
@export var levelOnePatterns : Array[PackedScene]
@export var levelTwoPatterns : Array[PackedScene]
@export var levelThreePatterns : Array[PackedScene]
@export var levelFourPatterns : Array[PackedScene]
@export var levelFivePatterns : Array[PackedScene]
@export var levelSixPatterns : Array[PackedScene]
@export var levelSevenPatterns : Array[PackedScene]
@export var levelEightPatterns : Array[PackedScene]
@export var levelNinePatterns : Array[PackedScene]

var patternsByDifficulty : Dictionary = {}
var cooldownIndices : Dictionary = {}

func _ready() -> void:
	if (!SeedManager.playerSeedInput): SeedManager.setSeed()
	patternRng = RandomNumberGenerator.new()
	patternRng.seed = SeedManager.random.seed
	
	waveTimer.wait_time = 0.0
	patternsByDifficulty = {
		0: testPatterns,
		1: levelOnePatterns,
		2: levelTwoPatterns,
		3: levelThreePatterns,
		4: levelFourPatterns,
		5: levelFivePatterns,
		6: levelSixPatterns,
		7: levelSevenPatterns,
		8: levelEightPatterns,
		9: levelNinePatterns
	}
	# ScoreCounter.setLevel(3)

func _on_wave_timer_timeout() -> void:
	# increase difficulty when threshold is met
	if ScoreCounter.currentLevel != 0 && levelProgressBar != null && levelProgressBar.levelUp():
		totalWaves = 1
		waveTimer.wait_time = 3.0 - (0.04 * ScoreCounter.currentLevel)
	currentList = patternsByDifficulty[ScoreCounter.currentLevel]
	
	# get all available indices that aren't on cooldown
	var availableIndices : Array = []
	for i in currentList.size():
		if i not in cooldownIndices:
			availableIndices.append(i)
	
	# fall back to all indices if everything is on cooldown
	if availableIndices.is_empty():
		availableIndices = range(currentList.size())
	
	# spawn a pattern
	var chosenIndex = availableIndices[patternRng.randi_range(0, availableIndices.size() - 1)]
	var currentWave = currentList[chosenIndex].instantiate()
	currentWave.setBulletSpeed(totalWaves, ScoreCounter.currentLevel)
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
	
	# set next wave's timer based on current level
	if ScoreCounter.currentLevel == 1:
		waveTimer.wait_time = 5.0
	elif totalWaves < 1:
		waveTimer.wait_time = 3.0
	else:
		waveTimer.wait_time *= 0.995
	
	# increase wave count
	totalWaves += 1
