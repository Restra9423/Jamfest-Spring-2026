extends CharacterBody2D
var speed = 650
var acceleration = 18
var friction = 12
var direction = Vector2.ZERO

var health = 3
var points = 0

var iFramesActive = false
@onready var iFrames : Timer = $iFrames
var parrying = false
var parried = false
@onready var parryLength : Timer = $ParryLength
var onCooldown = false
@onready var parryCooldown : Timer = $ParryCooldown
var hitMaybe = false
@onready var parryAfter : Timer = $ParryAfter
@onready var parryWindow : Area2D = $ParryPivot/ParryWindow

var avgMouseMove = [Vector2.ZERO, Vector2.ZERO, Vector2.ZERO]
var lastMousePos = Vector2.ZERO
@onready var parryPivot : Node2D = $ParryPivot

@export var scoreCounter: Control

@onready var parrySprite : Sprite2D = $ParryPivot/Sprite2D

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED_HIDDEN)

func _process(delta: float) -> void:
	if(health < 1):
		get_tree().change_scene_to_file("res://UI/title.tscn")
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
	
	var parryDir = (avgMouseMove[0]+avgMouseMove[1]+avgMouseMove[2])/3
	if(get_global_mouse_position() - lastMousePos != Vector2.ZERO):
		parryPivot.rotation = lerp(Vector2.ZERO,parryDir.normalized(),lerpWeight).angle()
		avgMouseMove.append(get_global_mouse_position() - lastMousePos)
		avgMouseMove.pop_front()
	lastMousePos = get_global_mouse_position()
	
	if(Input.is_action_just_pressed("Parry") && !onCooldown):
		parryLength.start()
		parrying = true
		print("parry clicked")
	if(hitMaybe && parryAfter.time_left == 0):
		hitMaybe = false

func _on_area_2d_body_entered(body: Node2D) -> void:
	hurt()

func _on_area_2d_area_entered(area: Area2D) -> void:
	hitMaybe = true
	parryAfter.start()
	await parryAfter.timeout
	if(hitMaybe):
		hurt()
		area.queue_free()
	elif(area.isParryable):
		parry(area.pointValue)
		area.setParried()
	hitMaybe = false

func _on_parry_window_area_entered(area: Area2D) -> void:
	print("bunger")
	if(area.isParryable):
		parry(area.pointValue)
		area.setParried()

func parry(pointValue: int):
	scoreCounter.incrementScore(pointValue)
	print("parry")
	
func hurt():
	if(!iFramesActive):
		iFrames.start()
		health -= 1
		iFramesActive = true
		print("hit")

func _on_i_frames_timeout() -> void:
	iFramesActive = false
func _on_parry_timer_timeout() -> void:
	parrying = false
	parryCooldown.start()
	onCooldown = true
	print("parry end")
	if(!parried):
		parryCooldown.wait_time = 2
func _on_parry_cooldown_timeout() -> void:
	if(parryCooldown.wait_time == 2):
		parryCooldown.wait_time = 1
	onCooldown = false
