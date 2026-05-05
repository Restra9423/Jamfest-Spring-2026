extends CharacterBody2D

#asset references
@export var health3: Node2D
@export var health2: Node2D
@export var health1: Node2D
@onready var playerSprite = $Area2D/AnimatedSprite2D
@onready var parrySprite : Sprite2D = %ParrySprite

@export var parryTextureWhite: Texture
@export var parryTextureOrange: Texture
@export var parryTexturePurple: Texture

#timers references
@onready var iFrames : Timer = $iFrames
@onready var parryLength : Timer = $ParryLength
@onready var parryCooldown : Timer = $ParryCooldown

#movement variables
var speed = 650
var acceleration = 18
var friction = 12
var moveInput = Vector2.ZERO

#status variables
var health = 3
var points = 0
var parryDir = Vector2.ZERO
var parrying = false
var parried = false

#input initialization
@onready var parryPivot : Node2D = $ParryPivot
@export var parryZone : Area2D
var mouseInput = Vector2.ZERO
var aimInput = Vector2.ZERO

#score
@export var scoreManager : Panel
var totalHeals : int = 0

#start and update functions
func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _process(delta: float) -> void:
	#death state check
	if health < 1:
		get_tree().change_scene_to_file("res://UI/death.tscn")
	
	#heal check
	@warning_ignore("integer_division")
	if totalHeals < ScoreCounter.currentScore/10000:
		heal()
		totalHeals += 1
	
	#parry state check
	if parryLength.time_left > 0:
		parrySprite.texture = parryTextureOrange
	elif parryCooldown.time_left > 0:
		parrySprite.texture = parryTexturePurple
	else:
		parrySprite.texture = parryTextureWhite
	
	#get input
	moveInput = Vector2(Input.get_axis("Left", "Right"), Input.get_axis("Up", "Down")).normalized()
	aimInput = Vector2(Input.get_axis("AimLeft", "AimRight"), Input.get_axis("AimUp", "AimDown")).normalized()
	if aimInput != Vector2.ZERO:
		parryDir = aimInput
	elif mouseInput.length() >= SettingsManager.mouseSensitivity:
		parryDir = mouseInput.normalized()
	
	#move player
	var lerpWeight = delta * (acceleration if moveInput else friction)
	velocity = lerp(velocity, moveInput * speed, lerpWeight)
	move_and_slide()
	
	#move parry zone
	if parryDir != Vector2.ZERO:
		parryPivot.rotation = lerp(Vector2.ZERO,parryDir,1).angle()
	
	#parry check
	if Input.is_action_just_pressed("Parry") && parryCooldown.time_left == 0:
		parrying = true
		parryLength.start()

func _physics_process(_delta: float) -> void:
	for area in parryZone.get_overlapping_areas():
		if parryLength.time_left > 0 && area.isParryable && !area.parriedBullet:
			if parried:
				scoreManager.makePointDisplay(area.global_position, area.pointValue/4, "Weak Parry")
			else:
				scoreManager.makePointDisplay(area.global_position, area.pointValue/2, "Weak Parry")
			parry(area.pointValue/2)
			if area.is_in_group("landmines"):
				hurt()
			area.setParried(((parryDir + self.position.direction_to(area.position))/2).normalized())



#collision functions
func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.is_in_group("bullets") && !area.parriedBullet:
		hurt()
		area.queue_free()

func _on_parry_zone_area_entered(area: Area2D) -> void:
	if parryLength.time_left > 0 && area.isParryable && !area.parriedBullet:
		if parried:
			scoreManager.makePointDisplay(area.global_position, area.pointValue/2, "none")
		else:
			scoreManager.makePointDisplay(area.global_position, area.pointValue, "none")
		parry(area.pointValue)
		if area.is_in_group("landmines"):
			hurt()
		area.setParried(((parryDir + self.position.direction_to(area.position))/2).normalized())


#custom functions
func parry(pointValue: int):
	if parried:
		@warning_ignore("integer_division")
		ScoreCounter.incrementScore(pointValue/2)
	else:
		ScoreCounter.incrementScore(pointValue)
		parried = true
	if parryLength.time_left > 0 && !(parryLength.wait_time - parryLength.time_left < 0.1):
		parryLength.wait_time = parryLength.time_left + 0.15
		parryLength.start()
	AudioController.playSFX(AudioController.parryHitSound)
	scoreManager.updateScore()
	var parryTween = get_tree().create_tween()
	parryTween.tween_property(parrySprite, "position:x", 110.0, 0.06).set_trans(Tween.TRANS_BOUNCE)
	parryTween.tween_property(parrySprite, "position:x", 75.635, 0.10).set_trans(Tween.TRANS_BOUNCE)
	

func hurt():
	print("hurt function called")
	if !iFrames.time_left > 0:
		iFrames.start()
		health -= 1
		parryLength.stop()
		parryLength.wait_time = parryLength.wait_time
		parryLength.timeout.emit()
		ScoreCounter.resetCombo()
		scoreManager.updateCombo()
		blink()
		AudioController.playSFX(AudioController.takeDamageSound, true)
		match health:
			2:
				health3.visible = false
			1:
				health2.visible = false

func blink():
	while iFrames.time_left > 0:
		playerSprite.visible = !playerSprite.visible
		await get_tree().create_timer(0.1).timeout
	playerSprite.visible = true

func heal():
	if health < 3:
		health += 1
		match health:
			3:
				health3.visible = true
			2:
				health2.visible = true
		AudioController.playSFX(AudioController.healingSound, true)


#timer functions
func _on_parry_length_timeout() -> void:
	if parryLength.wait_time != 0.3:
		parryLength.wait_time = 0.3
	if !parrying:
		parryCooldown.wait_time = 0.3
	elif !parried:
		AudioController.playSFX(AudioController.parryMissSound)
		parryCooldown.wait_time = 2
		ScoreCounter.resetCombo()
		scoreManager.updateCombo()
	else:
		parried = false
		ScoreCounter.incrementCombo()
		scoreManager.updateCombo()
	
	parrying = false
	parryCooldown.start()

func _on_parry_cooldown_timeout() -> void:
	if parryCooldown.wait_time != 1:
		parryCooldown.wait_time = 1



#input functions
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		mouseInput = event.get_relative()
