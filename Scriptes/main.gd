extends Node3D

@onready var menu : Menu = $MenuLayer/Menu

var menu_opened : bool = false

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("open_menu"):
		if menu.aerostats.size() == 0:
			return
		
		menu_opened = not menu_opened
		if menu_opened:
			menu.show()
			menu.start()
			menu.active = true
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			menu.hide()
			menu.active = false
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	if Input.is_action_just_pressed("exit_program"):
		get_tree().quit()