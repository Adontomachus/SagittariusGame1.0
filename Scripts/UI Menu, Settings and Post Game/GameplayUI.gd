extends Control

@export var pause_screen : Control
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass



func _on_pause_button_pressed() -> void:
	pause_screen.visible = true
	get_tree().paused = true
	Global.can_control_unit = false
	print("Can move unit: ", Global.can_control_unit)
