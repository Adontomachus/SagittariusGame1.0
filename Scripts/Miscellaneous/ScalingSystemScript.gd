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

var _cached_difficulty: int = 1
var _health_rate: float = 0.008
var _attack_rate: float = 0.002

var health_scaling: float = 1
var attack_power_scaling: float = 1
var time_accumulator: float = 0.0

func _ready() -> void:
	if not _initialized:
		health_scaling = 1
		attack_power_scaling = 1
		health_scaling += difficulty_scale
		_initialized = true

	## Load difficulty once and cache it
	call_deferred("_load_difficulty")
	_update_scaling_rates()
	
func _load_difficulty() -> void:
	var loaded = SaveSettings._load_difficulty_settings()
	_cached_difficulty = loaded if loaded != null else 1
	_update_scaling_rates()

func _update_scaling_rates() -> void:
	match _cached_difficulty:
		0:
			_health_rate = 0.003
			_attack_rate = 0.001
		1:
			_health_rate = 0.008
			_attack_rate = 0.002
		2:
			_health_rate = 0.02
			_attack_rate = 0.01

func _process(delta: float) -> void:
	var current_scene = get_tree().current_scene
	if current_scene == null or current_scene.name != "SpawnArea":
		return
	health_scaling += _health_rate * delta
	attack_power_scaling += _attack_rate * delta

func reset_scaling() -> void:
	_initialized = false
	health_scaling = 1 + difficulty_scale
	attack_power_scaling = 1
	_cached_difficulty = SaveSettings._load_difficulty_settings()
	_update_scaling_rates()
	_initialized = true
	
#For scaling purposes
func increment_scaling() -> void:

	return
