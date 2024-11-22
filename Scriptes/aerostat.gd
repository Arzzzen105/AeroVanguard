class_name Aerostat extends Node3D

@onready var anim = $AnimationPlayer
@onready var camera_position : Marker3D = $CameraPlacement

func _ready() -> void:
	anim.play("spawn")

func get_camera_postion() -> Vector3:
	var result : Vector3
	return result
