class_name Computer extends StaticBody3D

@export var world : Node3D

@onready var cameras : Array[Camera3D] = [
	$SubViewport/CanvasLayer/Control/GridContainer/SubViewportContainer/Screen1/Camera,
	$SubViewport/CanvasLayer/Control/GridContainer/SubViewportContainer2/Screen2/Camera,
	$SubViewport/CanvasLayer/Control/GridContainer/SubViewportContainer3/Screen3/Camera,
	$SubViewport/CanvasLayer/Control/GridContainer/SubViewportContainer4/Screen4/Camera
]
@onready var viewports : Array[SubViewport] = [
	$SubViewport/CanvasLayer/Control/GridContainer/SubViewportContainer/Screen1,
	$SubViewport/CanvasLayer/Control/GridContainer/SubViewportContainer2/Screen2,
	$SubViewport/CanvasLayer/Control/GridContainer/SubViewportContainer3/Screen3,
	$SubViewport/CanvasLayer/Control/GridContainer/SubViewportContainer4/Screen4
]
@onready var subviewport_containers : Array[SubViewportContainer] = [
	$SubViewport/CanvasLayer/Control/GridContainer/SubViewportContainer,
	$SubViewport/CanvasLayer/Control/GridContainer/SubViewportContainer2,
	$SubViewport/CanvasLayer/Control/GridContainer/SubViewportContainer3,
	$SubViewport/CanvasLayer/Control/GridContainer/SubViewportContainer4,
]

var aerostats_count : int = 0

var aerostats : Array[Aerostat] = []

func _ready() -> void:
	world = get_parent().get_parent()
	for i in range(4):
		viewports[i].world_3d = world.get_world_3d();
		subviewport_containers[i].hide()
		cameras[i].fov = 90

func add_camera(aerostat : Aerostat) -> void:
	
	if aerostats_count > 3:
		return
	 
	cameras[aerostats_count].global_position = aerostat.global_position
	subviewport_containers[aerostats_count].show()
	aerostats.append(aerostat)
	
	aerostats_count += 1

func _physics_process(delta: float) -> void:
	for i in range(aerostats.size()):
		cameras[i].global_position = aerostats[i].global_position
