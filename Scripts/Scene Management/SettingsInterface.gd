extends Control

@export_category("Main Menu node to set visible")
@export var main_menu_node: MarginContainer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_back_button_pressed() -> void:
	main_menu_node.visible = true
	self.visible = false

#region Seek values
func _on_volume_progress_value_changed(value: float) -> void:
	pass # Replace with function body.
func _on_sfx_slider_value_changed(value: float) -> void:
	pass # Replace with function body.
func _on_music_slider_value_changed(value: float) -> void:
	pass # Replace with function body.
#endregion
