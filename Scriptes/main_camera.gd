extends Camera3D

@export var character : CharacterBody3D
@export var camera_height : float = 1.7

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	position = character.global_position + Vector3(0, camera_height, 0)
	rotation = character.rotation
