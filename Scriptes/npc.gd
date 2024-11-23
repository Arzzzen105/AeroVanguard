class_name NPC extends CharacterBody3D

@onready var walk_timer: Timer = $WalkTimer
@onready var sleep_timer: Timer = $SleepTimer
@onready var mesh: MeshInstance3D = $Mesh


@export var speed : int = 120
@export var temperature : float = 1.0

var direction : Vector2
var gravity_modifier : float = 1.5

@onready var gravity = ProjectSettings.get_setting("physics/3d/default_gravity") * gravity_modifier

func _ready():
	direction = Vector2.ZERO
	sleep_timer.start()

func _physics_process(delta: float) -> void:
	
	if not is_on_floor():
		velocity.y -= gravity * delta
	
	velocity.x = direction.x * speed * delta
	velocity.z = direction.y * speed * delta
	move_and_slide()
	if global_position.y < -100:
		queue_free()

func _on_sleep_timer_timeout() -> void:
	direction = Vector2(randi_range(-100, 100), randi_range(-100, 100))
	direction = direction.normalized()
	walk_timer.start()

func _on_walk_timer_timeout() -> void:
	direction = Vector2.ZERO
	sleep_timer.start()
