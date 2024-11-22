class_name Menu extends Control

@export var world : Node3D

@onready var subviewport_container = $MarginContainer/PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/PanelContainer/SubViewportContainer
@onready var viewport = $MarginContainer/PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/PanelContainer/SubViewportContainer/SubViewport
@onready var aerostats_container = $MarginContainer/PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/MarginContainer/VBoxContainer/ScrollContainer/AerostatsContainer
@onready var camera = $MarginContainer/PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/PanelContainer/SubViewportContainer/SubViewport/Camera3D

const AEROSTAT_BUTTON_SCENE : PackedScene = preload("res://Scenes/aerostat_button.tscn")
var aerostats : Array[Aerostat] = []
var current : int = -1
var active : bool = false

func _physics_process(delta: float) -> void:
	if not active:
		return
	
	camera.global_position = aerostats[current].camera_position.global_position

func _ready():
	viewport.world_3d = world.get_world_3d()

func start():
	current = 0
	change_current(current)

func add_aerostat(new_aerostat : Aerostat):
	aerostats.append(new_aerostat)
	var new_button : AerostatButton = AEROSTAT_BUTTON_SCENE.instantiate()
	new_button.aerostat_number = aerostats.size()
	new_button.text = "Aerostat №" + str(new_button.aerostat_number)
	new_button.pressed.connect(change_current.bind(new_button.aerostat_number - 1))
	aerostats_container.add_child(new_button)

func change_current(num : int):
	current = num
	camera.global_position = aerostats[current].camera_position.global_position
	camera.global_rotation.y = aerostats[current].camera_position.global_rotation.y
