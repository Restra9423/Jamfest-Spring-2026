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
var patternTypeCooldownIndices : Dictionary = {}
var patternTypeCooldowns : Dictionary = {
	"Bonus": 15.0,
	"Bouncy": 5.0,
	"Circle": 2.0,
	"Sniper": 5.0,
	"Wall": 10.0
}

func _ready() -> void:
	if (!SeedManager.playerSeedInput): SeedManager.setSeed()
	patternRng = RandomNumberGenerator.new()
	patternRng.seed = SeedManager.random.seed
	
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
	
	_on_wave_timer_timeout.call_deferred()

func _on_wave_timer_timeout() -> void:
	# increase difficulty when threshold is met
	if ScoreCounter.currentLevel != 0 && levelProgressBar != null && levelProgressBar.levelUp():
		totalWaves = 1
		waveTimer.wait_time = 3.0 - (0.08 * ScoreCounter.currentLevel)
	currentList = patternsByDifficulty[ScoreCounter.currentLevel]
	
	# get all available indices that aren't on cooldown
	var availableIndices : Array = []
	var availableTypes : Array = []
	for i in currentList.size():
		if i not in cooldownIndices:
			availableIndices.append(i)
		
		var temp = currentList[i].instantiate()
		var type = temp.patternType
		temp.free()
		
		if type != "" && type not in patternTypeCooldownIndices:
			availableTypes.append(type)
	
	# fall back to all indices if everything is on cooldown
	if availableIndices.is_empty():
		availableIndices = range(currentList.size())
	
	# spawn a pattern, do not spawn if its type is on cooldown
	var chosenIndex = availableIndices[patternRng.randi_range(0, availableIndices.size() - 1)]
	var temp = currentList[chosenIndex].instantiate()
	var chosenType = temp.patternType
	if chosenType != "":
		while chosenType not in availableTypes:
			availableIndices.remove_at(availableIndices.find(chosenIndex))
			if availableIndices.is_empty():
				availableIndices = range(currentList.size())
				break
			chosenIndex = availableIndices[patternRng.randi_range(0, availableIndices.size() - 1)]
	var currentWave = currentList[chosenIndex].instantiate()
	currentWave.setBulletSpeed(totalWaves, ScoreCounter.currentLevel)
	temp.free()
	
	# read rotation and mirror options from currentWave directly
	var chosenRotation : float = 0.0
	if "allowedRotations" in currentWave && !currentWave.allowedRotations.is_empty():
		chosenRotation = currentWave.allowedRotations[patternRng.randi_range(0, currentWave.allowedRotations.size() - 1)]
	var mirrorX : bool = false
	var mirrorY : bool = false
	if "canBeMirrored" in currentWave && currentWave.canBeMirrored:
		mirrorX = patternRng.randi_range(0, 1) == 1
		mirrorY = patternRng.randi_range(0, 1) == 1
	
	currentWave.appliedRotation = chosenRotation
	currentWave.appliedMirrorX = mirrorX
	currentWave.appliedMirrorY = mirrorY
	var currentPatternType = currentWave.patternType if "patternType" in currentWave else ""
	var currentSpawnCooldown = currentWave.spawnCooldown if "spawnCooldown" in currentWave else 0.0
	
	add_child(currentWave)
	await get_tree().process_frame
	
	# create cooldown timer if pattern has a spawnCooldown
	if currentSpawnCooldown > 0.0:
		var cooldownTimer = Timer.new()
		add_child(cooldownTimer)
		cooldownTimer.wait_time = currentSpawnCooldown
		cooldownTimer.one_shot = true
		cooldownIndices[chosenIndex] = cooldownTimer
		cooldownTimer.timeout.connect(func():
			cooldownIndices.erase(chosenIndex)
			cooldownTimer.queue_free()
		)
		cooldownTimer.start()
	
	# create pattern type cooldown timer if pattern has a type
	if currentPatternType != "":
		var patternTypeCooldownTimer = Timer.new()
		add_child(patternTypeCooldownTimer)
		patternTypeCooldownTimer.wait_time = patternTypeCooldowns[currentPatternType]
		patternTypeCooldownTimer.one_shot = true
		patternTypeCooldownIndices[currentPatternType] = patternTypeCooldownTimer
		
		patternTypeCooldownTimer.timeout.connect(func():
			patternTypeCooldownIndices.erase(currentPatternType)
			patternTypeCooldownTimer.queue_free()
		)
		patternTypeCooldownTimer.start()
	
	# set next wave's timer based on current level
	if ScoreCounter.currentLevel == 1:
		waveTimer.wait_time = 5.0
	else:
		waveTimer.wait_time *= 0.995
	
	# increase wave count
	totalWaves += 1
