class_name DecTree extends StaticBody3D

@export_range(0, 1, 0.1) var temperature : float = 0.5

func _ready() -> void:
	rotation.y = randf_range(0, 2*PI)
	scale *= randf_range(0.8, 1.2)
