extends Node3D

@export var turn_speed = 0.5

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	rotation.y += deg_to_rad(turn_speed) * delta
