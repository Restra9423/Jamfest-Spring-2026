extends CharacterBody2D
var speed = 650
var acceleration = 18
var friction = 12
var direction = Vector2.ZERO
var health = 3
var points = 0
var iFramesActive = false
@onready var iFrames : Timer = $iFrames

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	if(health < 1):
		get_tree().quit()
	else:
		direction = Vector2(Input.get_axis("Left", "Right"), Input.get_axis("Up", "Down")).normalized()
		var lerpWeight = delta * (acceleration if direction else friction)
		velocity = lerp(velocity, direction * speed, lerpWeight)
		move_and_slide()

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
