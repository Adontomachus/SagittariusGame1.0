extends Area2D

@export var url := "https://www.halohaloapp.com/series/74/526"
var hovering := false
var was_hovering := false
@onready var browser_window := get_tree().get_first_node_in_group("BrowserWindow")


func _ready() -> void:
	input_pickable = false
	await get_tree().create_timer(5.0).timeout
	input_pickable = true


func _process(_delta: float) -> void:
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


func _input(event: InputEvent) -> void:
	if not hovering:
		return
	if event is InputEventMouseButton \
	and event.button_index == MOUSE_BUTTON_LEFT \
	and event.pressed and input_pickable:
		## Pass true so browser window knows to end level on close
		browser_window.open(url, true, "https://www.halohaloapp.com/series/60/437")
		## Remove the tome once opened so player can't open it again
		queue_free()
