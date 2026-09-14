extends Node

var random = RandomNumberGenerator.new()
var playerSeedInput = false

func setSeed(seedInput = null):
	if (seedInput != null):
		random.seed = seedInput
		playerSeedInput = true
	else:
		random.seed = randi_range(10000000, 99999999)
		playerSeedInput = false

func validateSeed(seedInput) -> bool:
	if (seedInput.is_valid_int() && int(seedInput) >= 10000000 && int(seedInput) <= 99999999):
		return true
	return false
