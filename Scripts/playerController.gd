extends CharacterBody2D

#asset references
@export var health3: Node2D
@export var health2: Node2D
@export var health1: Node2D
@onready var sfx = $AudioStreamPlayer
@onready var playerSprite = $Area2D/AnimatedSprite2D
@onready var parrySprite : Sprite2D = $ParryPivot/Sprite2D
var parryhit_sound = preload("res://Sound/SFX/ParryPing8Bit_SFX.wav")
var parrymiss_sound = preload("res://Sound/SFX/Swing8Bit_SFX.wav")
var takedamage_sound = preload("res://Sound/SFX/TakeDamage8Bit_SFX.wav")

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
@onready var parryZone : Area2D = $ParryPivot/ParryZone
var mouseInput = Vector2.ZERO
var aimInput = Vector2.ZERO

#score
@export var scoreManager : Panel


#start and update functions
func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _process(delta: float) -> void:
	#death state check
	if(health < 1):
		get_tree().change_scene_to_file("res://UI/death.tscn")
	
	#parry state check
	if(parryLength.time_left > 0):
		parrySprite.texture = load("res://Art/OrangeShield.png")
	elif(parryCooldown.time_left > 0):
		parrySprite.texture = load("res://Art/PurpleShield.png")
	else:
		parrySprite.texture = load("res://Art/WhiteShield.png")
	
	#get input
	moveInput = Vector2(Input.get_axis("Left", "Right"), Input.get_axis("Up", "Down")).normalized()
	aimInput = Vector2(Input.get_axis("AimLeft", "AimRight"), Input.get_axis("AimUp", "AimDown")).normalized()
	if(aimInput != Vector2.ZERO):
		parryDir = aimInput
	elif(mouseInput.length() >= 5.0):
		parryDir = mouseInput.normalized()
	
	#move player
	var lerpWeight = delta * (acceleration if moveInput else friction)
	velocity = lerp(velocity, moveInput * speed, lerpWeight)
	move_and_slide()
	
	#move parry zone
	if(parryDir != Vector2.ZERO):
		parryPivot.rotation = lerp(Vector2.ZERO,parryDir,1).angle()
	
	#parry check
	if(Input.is_action_just_pressed("Parry") && parryCooldown.time_left == 0):
		parrying = true
		parryLength.start()



#collision functions
func _on_area_2d_area_entered(area: Area2D) -> void:
	if (area.is_in_group("bullets") && !area.parriedBullet):
		hurt()
		area.queue_free()

func _on_parry_zone_area_entered(area: Area2D) -> void:
	if(parryLength.time_left > 0 && area.isParryable && !area.parriedBullet):
		parry(area.pointValue)
		area.setParried(parryDir)
	else:
		await get_tree().create_timer(0.5).timeout
		if (is_instance_valid(area)):
			if(parryLength.time_left > 0 && area.isParryable && parryZone.overlaps_area(area) && !area.parriedBullet):
				parry(area.pointValue)
				area.setParried((parryDir + ((position - area.position) / 2)).normalized())



#custom functions
func parry(pointValue: int):
	if parried:
		ScoreCounter.incrementScore(pointValue/2)
	else:
		ScoreCounter.incrementScore(pointValue)
		parried = true
	if(parryLength.time_left > 0 && !(parryLength.wait_time - parryLength.time_left < 0.1)):
		parryLength.wait_time = parryLength.time_left + 0.15
		parryLength.start()
	sfx.stream = parryhit_sound
	sfx.play()
	scoreManager.updateScore()
	
func hurt():
	print("hurt function called")
	if(!iFrames.time_left > 0):
		iFrames.start()
		health -= 1
		parryLength.stop()
		parryLength.wait_time = parryLength.wait_time
		parryLength.timeout.emit()
		ScoreCounter.resetCombo()
		scoreManager.updateCombo()
		blink()
		sfx.stream = takedamage_sound
		sfx.play()
		match health:
			2:
				health3.visible = false
				print("heath 3 not visible")
			1:
				health2.visible = false
				print("heath 2 not visible")

func blink():
	while(iFrames.time_left > 0):
		playerSprite.visible = !playerSprite.visible
		await get_tree().create_timer(0.1).timeout
	playerSprite.visible = true



#timer functions
func _on_parry_length_timeout() -> void:
	if(parryLength.wait_time != 0.3):
		parryLength.wait_time = 0.3
	if(!parrying):
		parryCooldown.wait_time = 0.3
	elif (!parried):
		sfx.stream = parrymiss_sound
		sfx.play()
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
	if(parryCooldown.wait_time != 1):
		parryCooldown.wait_time = 1



#input functions
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		mouseInput = event.get_relative()
