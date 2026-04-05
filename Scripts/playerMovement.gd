extends CharacterBody2D
var speed = 650
var acceleration = 18
var friction = 12
var direction = Vector2.ZERO
var health = 3
var points = 0
var iFramesActive = false
@onready var iFrames : Timer = $iFrames
var avgMouseMove = [Vector2.ZERO, Vector2.ZERO, Vector2.ZERO]
var lastMousePos = Vector2.ZERO
@onready var parryPivot : Node2D = $ParryPivot

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED_HIDDEN)

func _process(delta: float) -> void:
	if(health < 1):
		get_tree().quit()
	direction = Vector2(Input.get_axis("Left", "Right"), Input.get_axis("Up", "Down")).normalized()
	var lerpWeight = delta * (acceleration if direction else friction)
	velocity = lerp(velocity, direction * speed, lerpWeight)
	move_and_slide()
	
	var parryDir = (avgMouseMove[0]+avgMouseMove[1]+avgMouseMove[2])/3
	if(get_global_mouse_position() - lastMousePos != Vector2.ZERO):
		parryPivot.rotation = lerp(Vector2.ZERO,parryDir.normalized(),lerpWeight).angle()
		avgMouseMove.append(get_global_mouse_position() - lastMousePos)
		avgMouseMove.pop_front()
	lastMousePos = get_global_mouse_position()

func _on_area_2d_body_entered(body: Node2D) -> void:
	hurt()
	#create obvious visual indicator
	#make ui update for health

func _on_area_2d_area_entered(area: Area2D) -> void:
	hurt()

func hurt():
	if(!iFramesActive):
		iFrames.start()
		health -= 1
		iFramesActive = true
		print("hit")
	else:
		pass

func _on_i_frames_timeout() -> void:
	iFramesActive = false
