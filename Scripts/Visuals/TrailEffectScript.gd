extends Node

@export var sprite_trail: Sprite2D

func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if (get_tree().get_frame() % 8) == 0:
		return
	pass
