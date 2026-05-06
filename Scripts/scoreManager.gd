extends Control
class_name ScoreManager

@export var scoreDisplay : Label
@export var comboDisplay : Label
@export var multiDisplay : Label
@onready var scoreAccumTimer : Timer = $ScoreAccumTimer

var accumulatedPoints : int = 0
var colorIndex : int = 0

var currentScoreDisplay : Node2D = null

@export var pointDisplays : PackedScene

static var instance: ScoreManager

func _init() -> void:
	instance = self

func updateScore():
	# check point accumulation, update score display
	var pointsEarned = ScoreCounter.currentScore - ScoreCounter.scoreBeforeNewPoints
	accumulatedPoints = pointsEarned
	scoreDisplay.text = str(ScoreCounter.currentScore)
	
	# reset timer each time points are earned
	scoreAccumTimer.start()
	
	# update or create the accumulation display
	if is_instance_valid(currentScoreDisplay):
		currentScoreDisplay.get_node("Label").text = "+" + str(accumulatedPoints)
		currentScoreDisplay.modulate.a = 1.0
	else:
		currentScoreDisplay = pointDisplays.instantiate()
		add_child(currentScoreDisplay)
		currentScoreDisplay.global_position = scoreDisplay.global_position + Vector2(scoreDisplay.size.x + 10, 0)
		currentScoreDisplay.get_node("Label").text = "+" + str(accumulatedPoints)
		currentScoreDisplay.get_node("Label").modulate = Color.CHARTREUSE
		currentScoreDisplay.get_node("Label").add_theme_font_size_override("font_size", 60)

func updateCombo():
	comboDisplay.text = str(int(ScoreCounter.combo))
	multiDisplay.text = str("(", 1.0 + snappedf(ScoreCounter.combo / 10, 0.1), "x)")

func clearCombo(combo : int):
	if combo > 0:
		var comboFade = pointDisplays.instantiate()
		var label = comboFade.get_node("Label")
		add_child(comboFade)
		
		comboFade.global_position = Vector2(comboDisplay.global_position.x + 60, comboDisplay.global_position.y)
		comboFade.comboLost(combo)
		
		comboDisplay.text = "0"
		multiDisplay.text = "(1.0x)"

func makePointDisplay(spawnPos : Vector2, points : int, modifier : String) -> void:
	var newDisplay = pointDisplays.instantiate()
	var label = newDisplay.get_node("Label")
	add_child(newDisplay)
	
	newDisplay.global_position = spawnPos
	newDisplay.setText(points, modifier)

func levelUp() -> void:
	var colors = [Color.YELLOW, Color.CORAL, Color.RED, Color.DARK_RED]
	var tween = create_tween().set_loops()
	tween.tween_callback(func():
		scoreDisplay.modulate = colors[colorIndex]
		colorIndex = (colorIndex + 1) % colors.size()
	).set_delay(0.1)
	
	await get_tree().create_timer(2.0).timeout
	tween.stop()
	scoreDisplay.modulate = Color.WHITE

func _on_score_accum_timer_timeout() -> void:
	ScoreCounter.scoreBeforeNewPoints = ScoreCounter.currentScore
	accumulatedPoints = 0
	if is_instance_valid(currentScoreDisplay):
		var tween = create_tween()
		tween.tween_property(currentScoreDisplay, "modulate:a", 0.0, 0.5)
		tween.tween_callback(currentScoreDisplay.queue_free)
		currentScoreDisplay = null
