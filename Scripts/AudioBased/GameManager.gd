class_name GManager
extends Node2D


@export var beatIndicator: Panel # = $InterfaceElements/HUD/BeatIndicator
var spawnTimer = randf_range(5,10)
@export var player: Node2D # = $"../Player"

# PAUSE UI
@onready var pause_screen: Control = $InterfaceElements/HUD/UI/PauseScreen
var gamePaused: int

# MUSICAL UI
@export var animation_player: AnimationPlayer # = beatIndicator.get_node("AnimationPlayer")

#LEVEL VARIABLES
var level_wave: int = 1
const DIFFICULTY_SCALE: float = 0.15
const DROP_WEIGHT_SCALE: float = 0.05
var difficultyMeter = 1
var pointDropWeight = 0.25
var comboCount = 0
@export var player_target: Marker2D # = $InterfaceElements/PlayerTarget


#SPAWNING VARIABLES
const enemyToSpawn = preload("res://UnitInstances/Telegraphs/EnemySpawnWarning.tscn")
var playerSpawnDistance = 200

#region UI Elements for displaying values along with game notifications
@onready var score: Label = $InterfaceElements/HUD/UI/PlayerInfo/Score
@onready var wave_counter: Label = $InterfaceElements/HUD/UI/PlayerInfo/WaveCounter
@onready var wave_notification: Label = $InterfaceElements/HUD/UI/WaveNotification
var notifDuration
#endregion

#region Enumerators for enemy spawning behaviors
enum spawningBehavior {
	Preparation,
	Spawning,
	FinalAggressive
}
@export var _spawningBehavior: spawningBehavior = spawningBehavior.Preparation

#endregion

func _ready():
	
	notifDuration = 8
	wave_notification.self_modulate.a = 0
	pause_screen.visible = false
	gamePaused = 0
	#animation_player.play("Pulse")
	pass

#region TEMPORARY FUNCTIONS, SUBJECT TO CHANGE	
func _nextWave():
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
	var enemyCount = get_tree().get_nodes_in_group("GeneralEnemyInstance").size()
	#region value display for UI
	wave_counter.text = "Wave: " + str(level_wave)
	#endregion
	
	#region notification for the next wave
	wave_notification.text = "WAVE " + str(level_wave) + " INCOMING!"
	if _spawningBehavior == spawningBehavior.Preparation && wave_notification.self_modulate.a <= 1 && notifDuration > 1:
		wave_notification.self_modulate.a += 1 * delta
	else:
		_spawningBehavior == spawningBehavior.Spawning
		wave_notification.self_modulate.a -= 1 * delta
		
	if GlobalBeatSync.lastBeat < GlobalBeatSync.beat:
		GlobalBeatSync.lastBeat = GlobalBeatSync.beat
		print("Testing! Beat Synced! Notification Duration: ", notifDuration)
		notifDuration -= 1
		
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
	if (spawnTimer < 0):
		print("Spawned Enemy!")
		spawnTimer = randf_range(2,3)
		_spawn_enemy()
			
	#region Randomization of enemy spawning with telegraph, usually in a considerable distance to player
	instantiationPositions = Vector2(player.global_position.x + randf_range(155,455), player.global_position.y + randf_range(155,455))
	#global_position = player_target.global_position
	#endregion
func _spawn_enemy():
	var enemy = enemyToSpawn.instantiate()
	enemy.position = instantiationPositions
	#if (randomNumber < 0.25):
	#	enemy.unitType = enemy.EnemyType.Normal				
	#else:
	#	enemy.unitType = enemy.EnemyType.Fodder
	#get_tree().get_root().call_deferred("add_child", enemy)
	#spawnTimer = randf_range(5,10)
	add_child(enemy)
