extends Node

@onready var damageBounds : Area2D = $DamageBounds
@onready var sprite : Sprite2D = $Sprite2D

func _ready() -> void:
	sprite.material.set_shader_parameter("value_shift", -0.5)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	for body in damageBounds.get_overlapping_bodies():
		if body.is_in_group("Player"):
			body.hurt()
