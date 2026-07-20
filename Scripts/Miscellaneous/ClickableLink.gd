extends Area2D

## List of URLs to show in order — first is opened immediately,
## rest are navigable via back/forward buttons
@export var url_list: Array[String] = [
	"https://www.halohaloapp.com/series/74/526",
	"https://www.halohaloapp.com/series/60/437"
]

var hovering := false
var was_hovering := false
@onready var browser_window := get_tree().get_first_node_in_group("BrowserWindow")


func _ready() -> void:
	input_pickable = false
	await get_tree().create_timer(3.0).timeout
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
		if url_list.is_empty():
			push_error("ClickableTome: url_list is empty")
			return
		browser_window.open(url_list[0], true, url_list)
		queue_free()
