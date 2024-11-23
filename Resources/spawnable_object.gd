class_name SpawnableObject extends Resource

@export_file() var scene_path : String
@export var count : int = 100
@export var scale_min = 0.8
@export var scale_max = 1.2
var scene : PackedScene

func _ready():
	scene = load(scene_path)
