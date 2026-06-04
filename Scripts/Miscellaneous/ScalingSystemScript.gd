class_name ScalingSystems
extends Node

## For reset
var _initialized: bool = false

var difficulty_scale: float = 0.15
const DROP_WEIGHT_SCALE: float = 0.05

# This variable scales according to the game's wave level
@export_category("Scaling Properties")
@export var difficulty_meter = 0
@export var level_scaling = 0
# This variable scales on how long the gameplay is, which rewards players with more points
@export var point_drop_weight = 0.25

var health_scaling: float = 1
var attack_power_scaling: float = 1
var time_accumulator: float = 0.0

func _ready() -> void:
	if not _initialized:
		health_scaling = 1
		attack_power_scaling = 1
		health_scaling += difficulty_scale
		_initialized = true
func _process(delta) -> void:
	##Testing purposes
	time_accumulator += delta
	# if get_tree().current_ssssdwwasdawddwsdcene.name == "GameplayScene":
	var current_scene = get_tree().current_scene
	if current_scene == null or current_scene.name != "Manager":
		return
	if time_accumulator >= 1.0:
		print("Testing health scaling mechanic: ", health_scaling)
		time_accumulator = 0.0 
		
	## Difficulty health and damage scaling for enemies 
	var difficulty_settings = SaveSettings._load_difficulty_settings()
	match difficulty_settings:
		0:
			health_scaling += 0.004 * delta
			attack_power_scaling += 0.001 * delta
		1:
			health_scaling += 0.008 * delta
			attack_power_scaling += 0.002 * delta
		2:
			health_scaling += 0.014 * delta
			attack_power_scaling += 0.007 * delta

	# Debug Purposes
	## print(health_scaling)
	return

func reset_scaling() -> void:
	_initialized = false
	health_scaling = 1
	attack_power_scaling = 1
	health_scaling += difficulty_scale
	
#For scaling purposes
func increment_scaling() -> void:

	return
