extends Node

var shot_bars: Array[TextureRect]
@export var shots_available: = 2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var bar_parent = $HBoxContainer
	for child in bar_parent.get_children():
		shot_bars.append(child)
	pass # Replace with function body.

func _update_shot_counter() -> void:
	for i in range(shot_bars.size()):
		shot_bars[i].visible = i < shots_available

func _process(delta) -> void:
	_update_shot_counter()
	pass
