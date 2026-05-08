extends Node
class_name UpgradeSystems

@export_category("Levels needed before player upgrades	")
@export var levels_required: int = 5

## This is set to true until level threshold has been reached
@export var upgrade_available_on_level_threshold: bool = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
