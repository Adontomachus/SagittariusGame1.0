class_name GManager
extends Node2D


@export var beatIndicator: Panel # = $InterfaceElements/HUD/BeatIndicator
var spawnTimer = randf_range(5,10)
@export var player: Node2D# = $"../Player"

# PAUSE UI
@onready var pause_screen: Control = $InterfaceElements/PauseScreen
var gamePaused: int

# MUSICAL UI
@export var animation_player: AnimationPlayer# = beatIndicator.get_node("AnimationPlayer")

#LEVEL VARIABLES
var level_wave: int = 1
const DIFFICULTY_SCALE: float = 0.15
const DROP_WEIGHT_SCALE: float = 0.05
var difficultyMeter = 1
var pointDropWeight = 0.25
var comboCount = 0
@export var player_target: Marker2D # = $InterfaceElements/PlayerTarget


#SPAWNING VARIABLES
const enemyToSpawn = preload("res://UnitInstances/Enemy.tscn")
var playerSpawnDistance = 200

func _ready():
	gamePaused = 0
	#animation_player.play("Pulse")
	pass

#TEMPORARY FUNCTIONS, SUBJECT TO CHANGE	
func _spawnEnemies():
	return

func _nextWave():
	return

func _increaseIncrements():
	return

#region Functions for game pausing
func _resumeGame():
	gamePaused = 0
	#get_tree().paused = false
	pass
	
func _pauseGame():
	gamePaused = 1
	#get_tree().paused = true
	pass


func _on_resume_button_pressed() -> void:
	_resumeGame()
	
func _pause_and_unpause_input():
		if (gamePaused == 1): 
			_pauseGame()
		elif (gamePaused == 0):
			_resumeGame()
#endregion
	
# SPAWNING WIP #
var randomNumber = randf_range(0,1)

var playerRadius = 300
var instantiationPositions: Vector2

func _process(delta):
	if Input.is_action_just_pressed("pause_action"):
		_pause_and_unpause_input()
	if gamePaused:
		get_tree().paused = true
	else:
		get_tree().paused = false
	# Spawning Enemies
	spawnTimer -= delta
	if (spawnTimer < 0):
		print("Spawned Enemy!")
		spawnTimer = randf_range(5,6)
		_spawn_enemy()
		
func _spawn_enemy():
	var enemy = enemyToSpawn.instantiate()
	enemy.position = self.global_position
	#if (randomNumber < 0.25):
	#	enemy.unitType = enemy.EnemyType.Normal				
	#else:
	#	enemy.unitType = enemy.EnemyType.Fodder
	#get_tree().get_root().call_deferred("add_child", enemy)
	#spawnTimer = randf_range(5,10)
	add_child(enemy)
