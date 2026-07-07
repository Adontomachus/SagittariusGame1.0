extends Area2D

@export var url := "https://halohaloapp.com"

var hovering := false
var was_hovering := false

@onready var browser_window := get_tree().get_first_node_in_group("BrowserWindow")

func _ready():
	input_pickable = true

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

	if hovering != was_hovering:
		Input.set_default_cursor_shape(
			Input.CURSOR_POINTING_HAND if hovering else Input.CURSOR_ARROW
		)

	was_hovering = hovering


func _input(event):

	if !hovering:
		return

	if event is InputEventMouseButton \
	and event.button_index == MOUSE_BUTTON_LEFT \
	and event.pressed:
		browser_window.open(url)
