extends Node2D

@onready var beatIndicator: Panel = $InterfaceElements/HUD/BeatIndicator

@onready var animation_player: AnimationPlayer = beatIndicator.get_node("AnimationPlayer")

#LEVEL VARIABLES
var level_wave: int = 1
const DIFFICULTY_SCALE: float = 0.15
const DROP_WEIGHT_SCALE: float = 0.05
var difficultyMeter = 1
var pointDropWeight = 0.25
var comboCount = 0

#SPAWNING VARIABLES
var playerSpawnDistance = 200

func _ready():
	animation_player.play("Pulse")

#TEMPORARY FUNCTIONS, SUBJECT TO CHANGE	
func _spawnEnemies():
	return

func _nextWave():
	return

func _increaseIncrements():
	return
