class_name DecTree extends StaticBody3D

func _ready() -> void:
	rotation.y = randf_range(0, 2*PI)
	scale *= randf_range(0.8, 1.2)
