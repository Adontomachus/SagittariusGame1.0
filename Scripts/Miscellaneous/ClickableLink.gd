extends Area2D

@export var url: String = "https://halohaloapp.com"

var hovering := false

func _ready():
	input_pickable = true

var was_hovering := false

func _process(_delta):
	var local_mouse := to_local(get_global_mouse_position())

	hovering = false

	for child in get_children():
		if child is CollisionShape2D:
			if child.shape and child.shape.collide(
				Transform2D.IDENTITY,
				child.shape,
				Transform2D(0, local_mouse)
			):
				hovering = true
				break

	## Only update cursor when state changes
	if hovering != was_hovering:
		if hovering:
			Input.set_default_cursor_shape(Input.CURSOR_POINTING_HAND)
		else:
			Input.set_default_cursor_shape(Input.CURSOR_ARROW)

	was_hovering = hovering

func _input(event):
	if hovering:
		if event is InputEventMouseButton:
			if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
				print("Opening URL:", url)
				OS.shell_open(url)
