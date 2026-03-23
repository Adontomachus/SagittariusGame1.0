class_name GManager
extends Node2D



@export var beatIndicator: Panel # = $InterfaceElements/HUD/BeatIndicator
var spawnTimer = randf_range(2,5)
@export var player: Node2D # = $"../Player"

# PAUSE UI
@onready var pause_screen: Control = $InterfaceElements/NewHUD/UI/PauseScreen
var gamePaused: int

# MUSICAL UI
@export var animation_player: AnimationPlayer # = beatIndicator.get_node("AnimationPlayer")

#LEVEL VARIABLES
var level_wave: int
var comboCount = 0
@export var player_target: Marker2D # = $InterfaceElements/PlayerTarget
#LEVEL VARIABLES

#region SPAWNING VARIABLES AND STATS
const enemyToSpawn = preload("res://UnitInstances/Telegraphs/EnemySpawnWarning.tscn")
var playerSpawnDistance = 250
var shapeCast: ShapeCast2D
var enemySpawnWeightCounter: int
var rarityWeight: float
@export var maxRarityValue: float
var enemySpawnCounter: int
var enemyCount: int

# This checks if its eligible for the next wave to spawn as well as points.
var waveCompleted: bool
#var playerPoints: int
#endregion

#region Signals Section
signal pulse_on_beat
signal scale_on_next_wave
#endregion

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
	enemySpawnCounter = 10
	actualMousePosition = get_global_mouse_position()
	notifDuration = 6
	nextDuration = 6
	wave_notification.self_modulate.a = 0
	pause_screen.visible = false
	gamePaused = 0
	#animation_player.play("Pulse")
	pass

#region TEMPORARY FUNCTIONS, SUBJECT TO CHANGE	
func _next_wave(rarityIncrement) -> void:
	rarityWeight += rarityIncrement
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
		# Emit rhythmic signals for the game aesthetics
		pulse_on_beat.emit()
		GlobalBeatSync.lastBeat = GlobalBeatSync.beat

		print("Testing! Beat Synced! Spawns Remaining: ", enemySpawnCounter)
		
		# If statements to check which enumerator the spawn manager currently is
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
		
	# If the completed notification ends, go to the next wave and increase stat increments
		if wave_notification.self_modulate.a < 0:
			_change_spawning_state(spawningBehavior.Preparation)
			scale_on_next_wave.emit()
			enemySpawnCounter = 10 + (level_wave * 2)
			level_wave += 1
			nextDuration = 8
			_next_wave(1)

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
	
	#region Spawning Enemies
	spawnTimer -= delta
	#if _spawningBehavior == spawningBehavior.Spawning:
	if (spawnTimer < 0 && enemySpawnCounter != 0 && _spawningBehavior == spawningBehavior.Spawning):
		print("Spawned Enemy!")
		spawnTimer = randf_range(2,3)
		enemySpawnCounter -= 1
		_spawn_enemy()
	#endregion Spawning Enemies		
			
	#region Randomization of enemy spawning with telegraph, usually in a considerable distance to player
	instantiationPositions = Vector2(player.global_position.x + randf_range(200,600), player.global_position.y + randf_range(155,455))
	#global_position = player_target.global_position
	#endregion
	
	
#region ENEMY SPAWNING FUNCTION	
func _check_if_area_free(area_position):
	
	
	return
func _spawn_enemy():
	if enemySpawnCounter >= 0:
		var enemy = enemyToSpawn.instantiate()
		enemy.rarityWeight = rarityWeight
		#if (enemyoverlaps_area())
		enemy.position = instantiationPositions
		add_child(enemy)

#endregion		

#region FUNCTION FOR MOUSE LOCATION		
func _locate_mouse_pointer():
	cursorLocator.global_position = (player_target.global_position + actualMousePosition) / 2
	return
#endregion

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
