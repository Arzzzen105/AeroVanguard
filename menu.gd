class_name Menu extends Control

@export var world : Node3D
@export var light : DirectionalLight3D
@export var rotation_degrees_speed : float = 2

@onready var subviewport_container = $MarginContainer/PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/PanelContainer/SubViewportContainer
@onready var viewport = $MarginContainer/PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/PanelContainer/SubViewportContainer/SubViewport
@onready var aerostats_container = $MarginContainer/PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/MarginContainer/VBoxContainer/ScrollContainer/AerostatsContainer
@onready var camera_container: Node3D = $MarginContainer/PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/PanelContainer/SubViewportContainer/SubViewport/CameraContainer
@onready var camera: Camera3D = $MarginContainer/PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/PanelContainer/SubViewportContainer/SubViewport/CameraContainer/Camera3D
@onready var coordinates_label: Label = $MarginContainer/PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/PanelContainer/SubViewportContainer/SubViewport/InfoLayer/Control/VBoxContainer/Coordinates
@onready var night_vision_effect = $MarginContainer/PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/PanelContainer/SubViewportContainer/SubViewport/CameraContainer/MeshInstance3D
@onready var night_vision_button: CheckButton = $MarginContainer/PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/PanelContainer/SubViewportContainer/SubViewport/InfoLayer/Control/VBoxContainer/NightVisionButton

const AEROSTAT_BUTTON_SCENE : PackedScene = preload("res://Scenes/aerostat_button.tscn")
var aerostats : Array[Aerostat] = []
var current : int = -1
var active : bool = false
var night_vision_enabled : bool = false

func _physics_process(delta: float) -> void:
	if not active:
		return
	
	camera_container.global_position = aerostats[current].camera_position.global_position
	
	var rotation_input : Vector2 = Input.get_vector("walk_left", "walk_right", "walk_front", "walk_back")
	
	if rotation_input.length():
		camera.rotate_x(-rotation_input.y * rotation_degrees_speed * delta)
		camera_container.rotate_y(-rotation_input.x * rotation_degrees_speed * delta)
	
	change_info()
	
func _ready():
	viewport.world_3d = world.get_world_3d()
	night_vision_effect.hide()
	night_vision_enabled = false

func start():
	camera.rotation = Vector3(-PI/2, 0, 0)
	current = 0
	night_vision_effect.hide()
	night_vision_enabled = false
	change_current(current)

func add_aerostat(new_aerostat : Aerostat):
	aerostats.append(new_aerostat)
	var new_button : AerostatButton = AEROSTAT_BUTTON_SCENE.instantiate()
	new_button.aerostat_number = aerostats.size()
	new_button.text = "Aerostat №" + str(new_button.aerostat_number)
	new_button.pressed.connect(change_current.bind(new_button.aerostat_number - 1))
	aerostats_container.add_child(new_button)

func change_current(num : int):
	camera.rotation = Vector3(-PI/2, 0, 0)
	current = num
	camera_container.global_position = aerostats[current].camera_position.global_position
	camera_container.global_rotation.y = aerostats[current].camera_position.global_rotation.y

func change_info():
	coordinates_label.text = "x: " + str(camera_container.global_position.x) + "\nz: " + str(camera_container.global_position.z) + "\nheight: " + str(camera_container.global_position.y)

func _on_night_vision_pressed(toggled_on: bool) -> void:
	night_vision_enabled = !night_vision_enabled
	
	light.shadow_enabled = !night_vision_enabled
	if night_vision_enabled:
		light.rotation_degrees.x = -90
		light.light_energy = 3
		night_vision_effect.show()
	else:
		light.rotation_degrees.x = 90
		light.light_energy = 0
		night_vision_effect.hide()
