extends CharacterBody2D
var speed = 650
var acceleration = 18
var friction = 12
var direction = Vector2.ZERO

var health = 3
var points = 0

@export var health3: Node2D
@export var health2: Node2D
@export var health1: Node2D

@onready var sfx = $AudioStreamPlayer
@onready var playerSprite = $Area2D/AnimatedSprite2D
var parryhit_sound = preload("res://Sound/SFX/ParryPing8Bit_SFX.wav")
var parrymiss_sound = preload("res://Sound/SFX/Swing8Bit_SFX.wav")
var takedamage_sound = preload("res://Sound/SFX/TakeDamage8Bit_SFX.wav")

var iFramesActive = false
@onready var iFrames : Timer = $iFrames
var parrying = false
var parried = false
@onready var parryLength : Timer = $ParryLength
var onCooldown = false
@onready var parryCooldown : Timer = $ParryCooldown
var hitMaybe = false
@onready var parryWindow : Area2D = $ParryPivot/ParryWindow

var avgMouseMove = [Vector2.ZERO, Vector2.ZERO, Vector2.ZERO]
var lastMousePos = Vector2.ZERO
@onready var parryPivot : Node2D = $ParryPivot
var aimDir = Vector2.ZERO

@export var scoreManager : Panel

@onready var parrySprite : Sprite2D = $ParryPivot/Sprite2D

var mouseInput = Vector2.ZERO

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED_HIDDEN)

func _process(delta: float) -> void:
	if(health < 1):
		get_tree().change_scene_to_file("res://UI/death.tscn")
	direction = Vector2(Input.get_axis("Left", "Right"), Input.get_axis("Up", "Down")).normalized()
	var lerpWeight = delta * (acceleration if direction else friction)
	velocity = lerp(velocity, direction * speed, lerpWeight)
	move_and_slide()
	
	if(parrying):
		parrySprite.texture = load("res://Art/OrangeShield.png")
	elif(onCooldown):
		parrySprite.texture = load("res://Art/PurpleShield.png")
	else:
		parrySprite.texture = load("res://Art/WhiteShield.png")
		
	var aimInput = Vector2(Input.get_axis("AimLeft", "AimRight"), Input.get_axis("AimUp", "AimDown")).normalized()
	var parryDir = mouseInput + aimInput
	
	if((get_global_mouse_position() - lastMousePos != Vector2.ZERO) || (aimInput != Vector2.ZERO)):
		parryPivot.rotation = lerp(Vector2.ZERO,parryDir,1).angle()
		avgMouseMove.append(get_global_mouse_position() - lastMousePos)
		avgMouseMove.pop_front()
	lastMousePos = get_global_mouse_position()
	
	if(Input.is_action_just_pressed("Parry") && !onCooldown):
		parryLength.start()
		parrying = true
		print("parry clicked")

func _on_area_2d_body_entered(_body: Node2D) -> void:
	hurt()

func _on_area_2d_area_entered(area: Area2D) -> void:
	if(area.isParryable && parrying):
		parry(area.pointValue)
		area.setParried()
	else:
		print("i was hit")
		hurt()
		area.queue_free()
		
	hitMaybe = false

func _on_parry_window_area_entered(area: Area2D) -> void:
	print("bunger")
	if(parrying && area.isParryable):
		parry(area.pointValue)
		area.setParried()
		parryLength.wait_time = parryLength.time_left + 0.05
		parryLength.start()

func parry(pointValue: int):
	sfx.stream = parryhit_sound
	sfx.play()
	parried = true
	ScoreCounter.incrementScore(pointValue)
	scoreManager.updateScore()
	print("parry")
	
func hurt():
	if(!iFramesActive):
		iFrames.start()
		health -= 1
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
		iFramesActive = true
		print("hit")

func _on_i_frames_timeout() -> void:
	iFramesActive = false

func _on_parry_timer_timeout() -> void:
	if(!parried):
		sfx.stream = parrymiss_sound
		sfx.play()
		parryCooldown.wait_time = 2
	parryCooldown.start()
	parrying = false
	onCooldown = true
	print("parry end")

func _on_parry_cooldown_timeout() -> void:
	if(parryCooldown.wait_time == 2):
		parryCooldown.wait_time = 1
	onCooldown = false
	parryLength.wait_time = 0.3

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		mouseInput = event.get_relative()

func blink():
	while(iFrames.time_left > 0):
		playerSprite.visible = !playerSprite.visible
		await get_tree().create_timer(0.1).timeout
	playerSprite.visible = true
