class_name ScalingSystems
extends Node

var difficulty_scale: float = 0.15
const DROP_WEIGHT_SCALE: float = 0.05

# This variable scales according to the game's wave level
@export_category("Scaling Properties")
@export var difficulty_meter = 0
@export var level_scaling = 0
# This variable scales on how long the gameplay is, which rewards players with more points
@export var point_drop_weight = 0.25

var health_scaling: float = 1

func _ready() -> void:
	health_scaling += difficulty_scale
func _process(delta) -> void:
	# if get_tree().current_scene.name == "GameplayScene":
	health_scaling += 0.006 * delta
	print("Testing health scaling mechanic: ", health_scaling)
	return
	
#For scaling purposes
func increment_scaling() -> void:

	return
