extends TextureRect

@onready var browser_window := get_parent().get_parent()
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.
func _gui_input(event):
	browser_window.forward_input(event)
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
