extends CharacterBody2D
var speed = 500
var direction = Vector2.ZERO
var health = 3
var points = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if(health < 1):
		get_tree().quit()
	else:
		var x = Input.get_axis("Left", "Right")
		var y = Input.get_axis("Up", "Down")
		direction.x = x
		direction.y = y
		#direction = direction.normalized()
		velocity = direction * speed
		move_and_slide()

func _on_area_2d_body_entered(body: Node2D) -> void:
	health -= 1
	#create obvious visual indicator
	#make ui update for health

func _on_area_2d_area_entered(area: Area2D) -> void:
	health -= 1
