extends Node


## This array has been made a variable to manage dynamic map changes
@export var levels: Array[Node] = []
## This variable checks the gameplay's current level
@export var current_level: int = 1
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
