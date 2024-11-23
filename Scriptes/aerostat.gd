class_name Aerostat extends Node3D

@onready var camera_position: Marker3D = $CameraPlacement

var y_tween : Tween 

func _ready() -> void:
	y_tween = get_tree().create_tween()
	y_tween.set_ease(Tween.EASE_IN_OUT)
	y_tween.tween_property(self, "global_position:y", 100, 15)
