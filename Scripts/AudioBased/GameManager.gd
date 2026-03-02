class_name GManager
extends Node2D



@export var beatIndicator: Panel # = $InterfaceElements/HUD/BeatIndicator
var spawnTimer = randf_range(5,10)
@export var player: Node2D # = $"../Player"

# PAUSE UI
@onready var pause_screen: Control = $InterfaceElements/NewHUD/UI/PauseScreen
var gamePaused: int

# MUSICAL UI
@export var animation_player: AnimationPlayer # = beatIndicator.get_node("AnimationPlayer")

#LEVEL VARIABLES
var level_wave: int
const DIFFICULTY_SCALE: float = 0.15
const DROP_WEIGHT_SCALE: float = 0.05
var difficultyMeter = 1
var pointDropWeight = 0.25
var comboCount = 0
@export var player_target: Marker2D # = $InterfaceElements/PlayerTarget
#LEVEL VARIABLES

#SPAWNING VARIABLES AND STATS
const enemyToSpawn = preload("res://UnitInstances/Telegraphs/EnemySpawnWarning.tscn")
var playerSpawnDistance = 200
var enemySpawnWeightCounter: int
var rarityWeight: float
var enemySpawnCounter: int
var enemyCount: int

# This checks if its eligible for the next wave to spawn as well as points.
var waveCompleted: bool
#var playerPoints: int
#SPAWNING VARIABLES AND STATS

#region UI Elements for displaying values along with game notifications
@onready var score: Label = $InterfaceElements/NewHUD/UI/PlayerInfo/Score
@onready var wave_counter: Label = $InterfaceElements/NewHUD/UI/PlayerInfo/WaveCounter
@onready var enemy_counter: Label = $InterfaceElements/NewHUD/UI/PlayerInfo/EnemyCounter
@onready var wave_notification: Label = $InterfaceElements/NewHUD/UI/WaveNotification
var notifDuration: float
var nextDuration: float
#endregion

#region Enumerators for enemy spawning behaviors
enum spawningBehavior {
	Preparation,
	Spawning,
	FinalAggressive,
	NextWave
}

@export var _spawningBehavior: spawningBehavior = spawningBehavior.Preparation
#endregion
# Locate the mouse position for the mouse locator
var actualMousePosition: Vector2
@onready var cursorLocator: Marker2D = $MouseLocator

func _ready():
	level_wave = 1
	rarityWeight = 3
	waveCompleted = false
	enemySpawnCounter = 5
	actualMousePosition = get_global_mouse_position()
	notifDuration = 6
	nextDuration = 6
	wave_notification.self_modulate.a = 0
	pause_screen.visible = false
	gamePaused = 0
	#animation_player.play("Pulse")
	pass

#region TEMPORARY FUNCTIONS, SUBJECT TO CHANGE	
func _next_wave() -> void:
	return
	
func _finish_wave() -> void:
	return

func _increaseIncrements():
	return
#endregion

#region Functions for game pausing
func _resumeGame():
	gamePaused = 0
	get_tree().paused = false
	pass
	
func _pauseGame():
	gamePaused = 1
	get_tree().paused = true
	pass
#endregion

func _on_resume_button_pressed() -> void:
	_resumeGame()
	
func _pause_and_unpause_input():
		if (get_tree().paused == false): 
			pause_screen.visible = true
			_pauseGame()
		elif (get_tree().paused == true):
			pause_screen.visible = false
			_resumeGame()
#endregion
	
# SPAWNING WIP #
var randomNumber = randf_range(0,1)

var playerRadius = 300
var instantiationPositions: Vector2

func _process(delta):
	
	# Gets the number of enemies present in the screen
	enemyCount = get_tree().get_nodes_in_group("GeneralEnemyInstance").size()
	#region value display for UI
	wave_counter.text = "Wave: " + str(level_wave)
	enemy_counter.text = "Enemies Left: " + str(enemyCount)
	score.text = "Score: " + str(PointSystemScript.playerScore)
	#endregion
	
	
#region NOTIFICATION FOR THE NEXT WAVE
	
	if _spawningBehavior == spawningBehavior.Preparation:
		wave_notification.self_modulate.a += 1 * delta
		if wave_notification.self_modulate.a >= 1: wave_notification.self_modulate.a = 1
	if notifDuration < 1:
		_change_spawning_state(spawningBehavior.Spawning)
		wave_notification.self_modulate.a -= 1 * delta
		if wave_notification.self_modulate.a < 0: 
			#wave_notification.visible = false
			wave_notification.self_modulate.a = 0
		
	if GlobalBeatSync.lastBeat < GlobalBeatSync.beat:
		GlobalBeatSync.lastBeat = GlobalBeatSync.beat
		print("Testing! Beat Synced! Spawns Remaining: ", enemySpawnCounter)
		if _spawningBehavior == spawningBehavior.Preparation:
			print("Preparation")
			wave_notification.text = "WAVE " + str(level_wave) + " INCOMING!"
		if _spawningBehavior == spawningBehavior.Spawning: print("Spawning")
		if _spawningBehavior == spawningBehavior.NextWave:
			print("Completed. Next Wave: ", nextDuration)
			nextDuration -= 1
		notifDuration -= 1

	if enemyCount == 0 && enemySpawnCounter == 0 && _spawningBehavior == spawningBehavior.Spawning:
		_change_spawning_state(spawningBehavior.NextWave)
		
	# If the current wave is completed
	if (_spawningBehavior == spawningBehavior.NextWave && nextDuration >= 1):
		if wave_notification.self_modulate.a >= 1: wave_notification.self_modulate.a = 1
		notifDuration = 8
		wave_notification.self_modulate.a += 1 * delta
		wave_notification.text = "WAVE " + str(level_wave) + " COMPLETED!"
	if (_spawningBehavior == spawningBehavior.NextWave && nextDuration < 1):
		wave_notification.self_modulate.a -= 1 * delta
		
		# IF THE COMPLETED NOTIF ENDS, GO TO THE NEXT WAVE AND INCREMENT WEIGHTS
		if wave_notification.self_modulate.a < 0:
			_change_spawning_state(spawningBehavior.Preparation)
			enemySpawnCounter = 5 + level_wave
			level_wave += 1
			nextDuration = 8

	# If the current wave is completed
		

		
#endregion
	
	
	#region Pause Menu
	if Input.is_action_just_pressed("pause_action"):
		_pause_and_unpause_input()
	if gamePaused:
		get_tree().paused = true
	else:
		get_tree().paused = false
	#endregion
	
	# Spawning Enemies
	spawnTimer -= delta
	#if _spawningBehavior == spawningBehavior.Spawning:
	if (spawnTimer < 0 && enemySpawnCounter != 0 && _spawningBehavior == spawningBehavior.Spawning):
		print("Spawned Enemy!")
		spawnTimer = randf_range(2,3)
		enemySpawnCounter -= 1
		_spawn_enemy()
			
	#region Randomization of enemy spawning with telegraph, usually in a considerable distance to player
	instantiationPositions = Vector2(player.global_position.x + randf_range(200,600), player.global_position.y + randf_range(155,455))
	#global_position = player_target.global_position
	#endregion
	
	
func _spawn_enemy():
	
	if enemySpawnCounter >= 0:
		var enemy = enemyToSpawn.instantiate()
		enemy.position = instantiationPositions
		#if (randomNumber < 0.25):
		#	enemy.unitType = enemy.EnemyType.Normal				
		#else:
		#	enemy.unitType = enemy.EnemyType.Fodder
		#get_tree().get_root().call_deferred("add_child", enemy)
		#spawnTimer = randf_range(5,10)
		add_child(enemy)
		
func _locate_mouse_pointer():
	cursorLocator.global_position = (player_target.global_position + actualMousePosition) / 2
	return

#TEMPORARY
func _check_if_eligible_next_wave(): 
	if enemySpawnCounter && enemyCount == 0:
		return
	return
#TEMPORARY

func _change_spawning_state(changeBehavior: spawningBehavior):
	_spawningBehavior = changeBehavior
	return
	


func set_value(boss_health: int) -> void:
	pass # Replace with function body.
	
#func modify_player_score(modification: int) -> void:
#	playerPoints += modification
#	score_modify.emit(modification)
