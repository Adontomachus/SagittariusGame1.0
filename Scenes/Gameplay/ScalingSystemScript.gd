class_name ScalingSystems
extends Node

const DIFFICULTY_SCALE: float = 0.15
const DROP_WEIGHT_SCALE: float = 0.05

# This variable scales according to the game's wave level
var difficulty_meter = 1
var level_scaling = 1
# This variable scales on how long the gameplay is, which rewards players with more points
var point_drop_weight = 0.25

var health_scaling: float

func ready() -> void:
	health_scaling = difficulty_meter + (DIFFICULTY_SCALE * level_scaling)
#For scaling purposes
func increment_scaling() -> void:
	return
