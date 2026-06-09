class_name GManager
extends Node2D

@export_category("Enemy Spawner")
@export var spawner_scene: PackedScene = preload("res://UnitInstances/Enemy Instances/SpawnerEnemy.tscn")
@export var spawner_count_per_wave: int = 3

@export var beatIndicator: Panel # = $InterfaceElements/HUD/BeatIndicator
var spawnTimer = randf_range(2,5)
@export var player: Node2D # = $"../Player"

## For the combo system scoring methods
@onready var combo_system: ComboSystems = $GameSystems/ComboSystem
var player_combo_level: int


# PAUSE UI
@onready var pause_screen: Control = $InterfaceElements/NewHUD/UI/PauseScreen
var gamePaused: int



#LEVEL VARIABLES
var level_wave: int
var comboCount = 0
@export var waves_remaining: int
@export var player_target: Marker2D # = $InterfaceElements/PlayerTarget
#LEVEL VARIABLES

#region SPAWNING VARIABLES AND STATS
const enemyToSpawn = preload("res://UnitInstances/Telegraphs/EnemySpawnWarning.tscn")
var playerSpawnDistance = 250
var shapeCast: ShapeCast2D
var enemySpawnWeightCounter: int
## Weighted enemy rarity values for spawning enemy variety
var rarityWeight: float
## This value increments the value per level, which makes it much more adjustable
var rarityWeightIncrement: float = 0.5
@export var maxRarityValue: float
var enemySpawnCounter: int
var enemyCount: int

# This checks if its eligible for the next wave to spawn as well as points.
var waveCompleted: bool
#endregion

#region Signals Section
signal pulse_on_beat
signal scale_on_next_wave
#endregion

#region UI Elements for displaying values along with game notifications
@onready var score: Label = $InterfaceElements/NewHUD/UI/PlayerInfo/Score
@onready var wave_counter: Label = $InterfaceElements/NewHUD/UI/PlayerInfo/WaveCounter
@onready var enemy_counter: Label = $InterfaceElements/NewHUD/UI/EnemyCounter
@onready var wave_notification: Label = $InterfaceElements/NewHUD/UI/WaveNotification
#@onready var ability_1_container: ColorRect = $InterfaceElements/NewHUD/UI/CompanionProgressBar/Ability1Container
#@onready var ability_2_container: BoxContainer = $InterfaceElements/NewHUD/UI/CompanionProgressBar/Ability2Container

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
#@onready var cursorLocator: Marker2D = $MouseLocator

## Sets up the spawning mechanics and pause
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
	pause_screen.visible = false
	pass
	
func _exitGame():
	get_tree().change_scene_to_file("res://Scenes/Interface/MainMenuScene.tscn")
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
	## Gets the player's current combo level
	player_combo_level = combo_system.combo_level
	## Gets the number of enemies present in the screen
	enemyCount = get_tree().get_nodes_in_group("GeneralEnemyInstance").size()
	#region value display for UI
	wave_counter.text = "Waves Remaining: " + str(waves_remaining)
	enemy_counter.text = "Enemies Left: " + str(enemyCount)
	score.text = "Score: " + str(PointSystemScript.playerScore)
	#endregion
	
	
#region NOTIFICATION FOR THE NEXT WAVE
	
	## This section handles the notification text that appear during wave
	## start and completion on top of the screen
	if _spawningBehavior == spawningBehavior.Preparation:
		wave_notification.self_modulate.a += 1 * delta
		if wave_notification.self_modulate.a >= 1: wave_notification.self_modulate.a = 1
	if notifDuration < 1:
		if _spawningBehavior != spawningBehavior.Spawning:  
			_change_spawning_state(spawningBehavior.Spawning)
		wave_notification.self_modulate.a -= 1 * delta
		if wave_notification.self_modulate.a < 0: 
			#wave_notification.visible = false
			wave_notification.self_modulate.a = 0
		
	## This 'if' statement comes from the global beat synchronization script's last beat
	## If the Last Beat variable is lower than the Beat value, Last Beat's value would
	## be higher than beat to ensure only a singlaaaae frame is updated.
	## Note that this might change for better optimization purposes.
	if GlobalBeatSync.lastBeat < GlobalBeatSync.beat:
		#region Signal emitters for beat synchronization
		# Emit rhythmic signals for the game aesthetics
		pulse_on_beat.emit()
		#endregion
	
		GlobalBeatSync.lastBeat = GlobalBeatSync.beat

		print("Testing! Beat Synced! Spawns Remaining: ", enemySpawnCounter)
		
		# 'If' statements to check which enumerator the spawn manager currently is
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
		if wave_notification.self_modulate.a < 0 && waves_remaining != 0:
			if _spawningBehavior != spawningBehavior.Preparation:
				waves_remaining -= 1
				_change_spawning_state(spawningBehavior.Preparation)
				scale_on_next_wave.emit()
				enemySpawnCounter = 10 + (level_wave * 2)
				level_wave += 1
				spawner_count_per_wave+=1
				nextDuration = 8
				_next_wave(rarityWeightIncrement)
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
	if (spawnTimer < 0 && enemySpawnCounter != 0 && _spawningBehavior == spawningBehavior.Spawning):
		print("Spawned Enemy!")
		spawnTimer = randf_range(2,3)
		enemySpawnCounter -= 1
		## Only spawn one enemy instance if it is the last wave
		if waves_remaining == 0: enemySpawnCounter = 0
		_spawn_enemy()
	#endregion 
			
	#region Randomization of enemy spawning with telegraph, usually in a considerable distance to player
	instantiationPositions = Vector2(player.global_position.x + randf_range(-650,650), player.global_position.y + randf_range(-310,310))
	#endregion
	
	
#region ENEMY SPAWNING FUNCTION	
func _check_if_area_free(area_position):
	
	return
func _spawn_enemy():
	#if enemySpawnCounter >= 0:
		#var enemy = enemyToSpawn.instantiate()
		#enemy.rarityWeight = rarityWeight
		##if (enemyoverlaps_area())
		#if waves_remaining == 0:
			#enemy.final_wave = true
		#enemy.position = instantiationPositions
		#add_child(enemy)
	pass

# spawns spawners
func _spawn_wave_spawners() -> void:
	for i in range(spawner_count_per_wave):
		if spawner_scene == null:
			push_error("GManager: spawner_scene not assigned")
			return
		var spawner = spawner_scene.instantiate()
		spawner.position = _get_random_spawn_position()
		spawner.rarityWeight = rarityWeight          
		spawner.final_wave = waves_remaining == 0   
		add_child(spawner)
		print("Spawned EnemySpawner ", i + 1, "/", spawner_count_per_wave)

func _get_random_spawn_position() -> Vector2:
	## Spawn away from player
	var player_pos := player.global_position
	var pos: Vector2
	var attempts := 0
	var max_attempts := 20
	## Keep trying until we find a spot far enough from the player
	while attempts < 10:
		pos = Vector2(
			randf_range(200, 2800),
			randf_range(200, 2800)
		)
		if pos.distance_to(player_pos) < 400.0:
			attempts += 1
			continue
			
		if _is_position_clear(pos):
			return pos
		attempts += 1
	push_warning("GManager: could not find clear spawn position after ", max_attempts, " attempts")
	return Vector2(
			player_pos.x + randf_range(-800, 800),
			player_pos.y + randf_range(-800, 800)
		)

func _is_position_clear(pos: Vector2) -> bool:
	var space := get_world_2d().direct_space_state

	## Circle to match spawner size
	var shape := CircleShape2D.new()
	shape.radius = 60.0  

	var query := PhysicsShapeQueryParameters2D.new()
	query.shape = shape
	query.transform = Transform2D(0, pos)
	query.collision_mask = 0xFFFFFFFF
	query.collide_with_bodies = true
	query.collide_with_areas = false  ## ignore areas, only solid bodies

	var results := space.intersect_shape(query)

	for result in results:
		var collider = result.collider
		## Block if overlapping obstacles or other spawners
		if collider.is_in_group("MapObstacle"):
			return false
		if collider is EnemySpawner:
			return false

	return true
#endregion		


func _change_spawning_state(changeBehavior: spawningBehavior) -> void:
	_spawningBehavior = changeBehavior
	if changeBehavior == spawningBehavior.Spawning:
		_spawn_wave_spawners()
	return
	
func set_value(boss_health: int) -> void:
	pass # Replace with function body.


func _on_pause_screen_exit_game() -> void:
	get_tree().change_scene_to_file("res://Scenes/Interface/MainMenuScene.tscn")
	pass # Replace with function body.


func _on_pause_screen_resume_game() -> void:
	_resumeGame()
	pass # Replace with function body.


func _add_combo_level(strength_value: float) -> void:
	pass # Replace with function body.
