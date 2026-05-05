extends Control
class_name ScoreManager

@export var scoreDisplay : Label
@export var comboDisplay : Label

@export var pointDisplays : PackedScene

static var instance: ScoreManager

func _init() -> void:
	instance = self

func updateScore():
	scoreDisplay.text = str(ScoreCounter.currentScore)

func updateCombo():
	comboDisplay.text = str(int(ScoreCounter.combo), "x")

func makePointDisplay(spawnPos : Vector2, points : int, modifier : String) -> void:
	var newDisplay = pointDisplays.instantiate()
	var label = newDisplay.get_node("Label")
	add_child(newDisplay)
	
	newDisplay.global_position = spawnPos
	newDisplay.setText(points, modifier)
