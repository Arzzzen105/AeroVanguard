class_name Player extends CharacterBody3D

@export var aerostats_container : Node3D
@export var menu : Menu

@export_group("Movement")
@export var max_speed : float = 4.0
@export var acceleration : float = 20.0
@export var braking : float = 20.0
@export var air_acceleration : float = 4.0
@export var jump_force : float = 5.0
@export var gravity_modifier : float = 1.5
@export var max_sprint_speed : float = 6.0
var is_running : bool = false

@export_group("Camera")
@export var camera_sensitivity : float = 0.005
@onready var camera : Camera3D = $Camera3D
var camera_input : Vector2
var active : bool = true

const AEROSTAT_SCENE : PackedScene = preload("res://Scenes/aerostat.tscn")

@onready var gravity = ProjectSettings.get_setting("physics/3d/default_gravity") * gravity_modifier

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _physics_process(delta):
	if not is_on_floor():
		velocity.y -= gravity * delta
	
	if not active:
		return
	
	if is_on_floor() and Input.is_action_pressed("jump"):
		velocity.y = jump_force
	
	var move_input : Vector2 = Input.get_vector("walk_left", "walk_right", "walk_front", "walk_back")
	
	is_running = Input.is_action_pressed("sprint")
	
	var target_speed = max_speed
	
	var move_dir = (transform.basis * Vector3(move_input.x, 0, move_input.y)).normalized()
	
	if is_running:
		target_speed = max_sprint_speed
		var run_dot = move_dir.dot(transform.basis.z)
		move_dir *= abs(run_dot)
	
	var current_smoothing = acceleration
	
	if not is_on_floor():
		current_smoothing = air_acceleration
	else:
		if not move_input:
			current_smoothing = braking
	
	var target_vel = move_dir * target_speed
	
	velocity.x = lerp(velocity.x, target_vel.x, current_smoothing * delta)
	velocity.z = lerp(velocity.z, target_vel.z, current_smoothing * delta)
	
	move_and_slide()
	
	rotate_y(- camera_input.x * camera_sensitivity)
	camera.rotate_x(- camera_input.y * camera_sensitivity)
	camera.rotation.x = clamp(camera.rotation.x, -1.5, 1.5)
	camera_input = Vector2.ZERO

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		camera_input = event.relative

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("iterract"):
		put_aerostat()
	
func put_aerostat():
	var aerostat = AEROSTAT_SCENE.instantiate()
	aerostats_container.add_child(aerostat)
	aerostat.position = position
	aerostat.rotation.y = rotation.y + PI/2
	menu.add_aerostat(aerostat)
