extends Node2D

var colorIndex : int = 0
@onready var displayText : Label = $Label
@onready var destroyTimer : Timer = $DestroyTimer

func _on_destroy_timer_timeout() -> void:
	#text fades out
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.5)
	tween.tween_callback(queue_free)

func setText(points : int, modifier : String):
	if points == 0:
		queue_free()
	if modifier == "Bonus":
		displayText.add_theme_font_size_override("font_size", 70)
		destroyTimer.wait_time = 1.0
		var colors = [Color.RED, Color.BLUE, Color.GREEN, Color.YELLOW, Color.PURPLE]
		var tween = create_tween().set_loops()
		tween.tween_callback(func():
			modulate = colors[colorIndex]
			colorIndex = (colorIndex + 1) % colors.size()
		).set_delay(0.1)
	if modifier == "Ricochet":
		if points < 200:
			displayText.add_theme_font_size_override("font_size", 25)
			displayText.modulate = Color.YELLOW_GREEN
		else:
			displayText.add_theme_font_size_override("font_size", 60)
			displayText.modulate = Color.SIENNA
	if modifier == "Weak Parry":
		if points < 75:
			displayText.add_theme_font_size_override("font_size", 25)
			displayText.modulate = Color.WEB_PURPLE
		elif points < 200:
			displayText.add_theme_font_size_override("font_size", 35)
			displayText.modulate = Color.PERU
		else:
			displayText.add_theme_font_size_override("font_size", 55)
			displayText.modulate = Color.WEB_MAROON
	if modifier == "none":
		if points < 150:
			pass
		elif points < 400:
			displayText.add_theme_font_size_override("font_size", 50)
			displayText.modulate = Color.GOLD
		else:
			displayText.add_theme_font_size_override("font_size", 70)
			displayText.modulate = Color.CRIMSON
	displayText.text = str(points)
	destroyTimer.start()

func comboLost(combo : int) -> void:
	displayText.text = str(combo)
	displayText.add_theme_font_size_override("font_size", 80)
	displayText.modulate = Color.RED
	
	$DestroyTimer.wait_time = 1.5
	$DestroyTimer.start()
	
	var tween = create_tween()
	tween.tween_property(self, "position:y", position.y - 50.0, 1.5)
	tween.parallel().tween_property(self, "modulate:a", 0.0, 1.5)
	tween.tween_callback(queue_free)
