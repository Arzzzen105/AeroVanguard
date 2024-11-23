class_name Menu extends Control

@export var world : Node3D
@export var light : DirectionalLight3D
@export var rotation_speed : float = 1
@export var zoom_speed : int = 30

@onready var subviewport_container = $MarginContainer/PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/PanelContainer/SubViewportContainer
@onready var viewport = $MarginContainer/PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/PanelContainer/SubViewportContainer/SubViewport
@onready var aerostats_container = $MarginContainer/PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/MarginContainer/VBoxContainer/ScrollContainer/AerostatsContainer
@onready var camera_container: Node3D = $MarginContainer/PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/PanelContainer/SubViewportContainer/SubViewport/CameraContainer
@onready var camera: Camera3D = $MarginContainer/PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/PanelContainer/SubViewportContainer/SubViewport/CameraContainer/CameraRotator/Camera3D
@onready var camera_rotator: Node3D = $MarginContainer/PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/PanelContainer/SubViewportContainer/SubViewport/CameraContainer/CameraRotator
@onready var coordinates_label: Label = $MarginContainer/PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/PanelContainer/SubViewportContainer/SubViewport/InfoLayer/Control/VBoxContainer/Coordinates
@onready var night_vision_effect = $MarginContainer/PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/PanelContainer/SubViewportContainer/SubViewport/CameraContainer/CameraRotator/Camera3D/MeshInstance3D
@onready var night_vision_button: CheckButton = $MarginContainer/PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/PanelContainer/SubViewportContainer/SubViewport/InfoLayer/Control/VBoxContainer/NightVisionButton
@onready var viewport_control: Control = $MarginContainer/PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/PanelContainer/SubViewportContainer/SubViewport/InfoLayer/Control


const AEROSTAT_BUTTON_SCENE : PackedScene = preload("res://Scenes/aerostat_button.tscn")
const BOX_THEME : Theme = preload("res://Resources/box_theme.tres")
var aerostats : Array[Aerostat] = []
var current : int = -1
var active : bool = false
var night_vision_enabled : bool = false
var detected_npcs : Array[NPC] = []
var space3d : PhysicsDirectSpaceState3D

func _physics_process(delta: float) -> void:
	
	for c in viewport_control.get_children():
		if c is Label or c is Panel:
			c.queue_free()
	
	detected_npcs.clear()
	
	if not active:
		return
	
	camera_container.global_position = aerostats[current].camera_position.global_position
	
	var rotation_input : Vector2 = Input.get_vector("walk_left", "walk_right", "walk_front", "walk_back")
	
	var zoom_input : int = Input.get_axis("zoom_out", "zoom_in")
	
	if zoom_input:
		#camera.position.z = clamp(camera.position.z - zoom_input * zoom_speed * delta, -1000, 0)
		camera.fov = clamp(camera.fov + zoom_speed * zoom_input * delta, 10, 90)
	
	if rotation_input.length():
		camera_rotator.rotate_x(-rotation_input.y * rotation_speed * delta)
		camera_container.rotate_y(-rotation_input.x * rotation_speed * delta)
	
	change_info()
	
	var frustum_planes : Array[Plane] = camera.get_frustum()
	var near : Plane = frustum_planes[0]
	var far : Plane = frustum_planes[1]
	var left : Plane = frustum_planes[2]
	var top : Plane = frustum_planes[3]
	var right : Plane = frustum_planes[4]
	var bottom : Plane = frustum_planes[5]
	for npc : NPC in get_tree().get_nodes_in_group("npcs"):
		
		var npc_pos = npc.global_position
		
		if near.is_point_over(npc_pos) != far.is_point_over(npc_pos) or left.is_point_over(npc_pos) != right.is_point_over(npc_pos) or top.is_point_over(npc_pos) != bottom.is_point_over(npc_pos):
			continue;
		
		var ray_data = PhysicsRayQueryParameters3D.create(camera_rotator.global_position, npc_pos, 2, [self])
		var intersection = space3d.intersect_ray(ray_data)
		
		if intersection:
			continue
		
		var screen_pos : Vector2 = camera.unproject_position(npc_pos)
		var box : Panel = Panel.new()
		box.theme = BOX_THEME
		viewport_control.add_child(box)
		box.size = Vector2(20, 40)
		box.position = screen_pos - box.size / 2 + Vector2(0, -10)
		
		
		var npc_label = Label.new()
		viewport_control.add_child(npc_label)
		npc_label.text = "x: " + str(int(npc_pos.x)) + "\nz: " + str(int(npc_pos.z))
		npc_label.position = screen_pos + Vector2(-30, -80)
	

func _ready():
	space3d = world.get_world_3d().direct_space_state
	camera.position.z = 0
	camera.rotation_degrees.z = 180
	camera_container.rotation.y = 0
	camera_rotator.rotation_degrees.x = -90
	camera.rotation = Vector3(0, 0, 0)
	viewport.world_3d = world.get_world_3d()
	night_vision_effect.hide()
	night_vision_enabled = false

func start():
	camera.position.z = 0
	camera.rotation_degrees.z = 180
	camera_container.rotation.y = 0
	camera_rotator.rotation_degrees.x = -90
	camera.rotation = Vector3(0, 0, 0)
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
	camera.position.z = 0
	camera.rotation_degrees.z = 180
	camera_container.rotation.y = 0
	camera_rotator.rotation_degrees.x = -90
	camera.rotation = Vector3(0, 0, 0)
	current = num
	camera_container.global_position = aerostats[current].camera_position.global_position
	camera_container.global_rotation.y = aerostats[current].camera_position.global_rotation.y

func change_info():
	coordinates_label.text = "x: " + str(int(camera_container.global_position.x)) + "\nz: " + str(int(camera_container.global_position.z)) + "\nheight: " + str(int(camera_container.global_position.y))

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
