class_name GManager
extends Node2D

# For boss spawn checking
var boss_spawned: bool = false

@export_category("Enemy Spawner")
@export var spawner_scene: PackedScene = preload("res://UnitInstances/Enemy Instances/SpawnerEnemy.tscn")
@export var spawner_count_per_wave: int = 3

@export var beatIndicator: Panel # = $InterfaceElements/HUD/BeatIndicator
@export var player: Node2D # = $"../Player"

## For the combo system scoring methods
@onready var combo_system: ComboSystems = $GameSystems/ComboSystem
var player_combo_level: int
@export var enemy_spawn_parent: Node2D

# PAUSE UI
@onready var pause_screen: Control = $InterfaceElements/NewHUD/UI/PauseScreen
var gamePaused: int

@onready var spawn_bounds: CollisionPolygon2D = $"GameLevelNode/Stage1/EnemyNavRegion/Map Objects/MapEdgeObstacles/StaticBody2D/SpawnArea"

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

@export var boss_scene: PackedScene = preload("res://UnitInstances/Enemy Instances/Boss.tscn")

func _spawn_boss() -> void:
	if boss_scene == null:
		push_error("GManager: boss_scene not assigned")
		return
	
	# lock to prevent multiple bosses
	if boss_spawned:
		return  
	boss_spawned = true

	var boss = boss_scene.instantiate()
	boss.position = _get_random_spawn_position()
	boss.boss_unit = true
	add_child(boss)
	print("Boss spawned!")
	_spawn_wave_spawners(6)
	player.camera._change_camera_focus_to_boss()
	await get_tree().create_timer(2.0).timeout
	player.camera._change_camera_focus_to_player()
	
	#while boss:
	#		_spawn_wave_spawners(1)
	#		await get_tree().create_timer(40.0).timeout
	

	## Update wave notification
	wave_notification.text = "FINAL WAVE — BOSS INCOMING!"

@onready var cef: GdCEF = $GdCEF
## Sets up the spawning mechanics and pause
func _ready() -> void:
	var success := cef.initialize({})
	if !success:
		push_error(cef.get_error())
	else:
		print("CEF initialized!")
		
	get_viewport().physics_object_picking = true
	print(get_viewport().physics_object_picking)
	add_to_group("GManager")
	is_transitioning = false
	boss_spawned = false
	level_wave = 1
	rarityWeight = 3
	waveCompleted = false
	notifDuration = 6
	nextDuration = 6
	wave_notification.self_modulate.a = 0
	pause_screen.visible = false
	gamePaused = 0

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

var spawning_grace_period: float = 3.0  
var time_since_spawning_started: float = 0.0
var is_transitioning: bool = false

func _process(delta: float) -> void:
	if _spawningBehavior == spawningBehavior.Spawning:
		enemyCount = get_tree().get_nodes_in_group("GeneralEnemyInstance").size()
		enemy_counter.text = "Enemies Left: " + str(enemyCount)
		time_since_spawning_started += delta
		## Fade out notification
		wave_notification.self_modulate.a = maxf(
			wave_notification.self_modulate.a - delta * 2.0, 0.0
		)
		## Wave completion check
		if time_since_spawning_started >= spawning_grace_period and enemyCount == 0:
			_change_spawning_state(spawningBehavior.NextWave)
	if _spawningBehavior == spawningBehavior.Preparation and not is_transitioning:
		wave_notification.self_modulate.a = minf(
			wave_notification.self_modulate.a + delta, 1.0
		)
	if _spawningBehavior == spawningBehavior.NextWave:
		if nextDuration >= 1:
			wave_notification.self_modulate.a = minf(
				wave_notification.self_modulate.a + delta, 1.0
			)
		else:
			is_transitioning = true
			wave_notification.self_modulate.a -= delta
			if wave_notification.self_modulate.a <= 0:
				wave_notification.self_modulate.a = 0
				is_transitioning = false
				if waves_remaining > 0:
					waves_remaining -= 1
					level_wave += 1
					spawner_count_per_wave = 3 + level_wave / 2
					notifDuration = 6
					nextDuration = 8
					time_since_spawning_started = 0.0
					_next_wave(rarityWeightIncrement)
					scale_on_next_wave.emit()
					_change_spawning_state(spawningBehavior.Preparation)
	if GlobalBeatSync.lastBeat < GlobalBeatSync.beat:
		pulse_on_beat.emit()
		GlobalBeatSync.lastBeat = GlobalBeatSync.beat
		player_combo_level = combo_system.combo_level
		notifDuration -= 1
		if _spawningBehavior == spawningBehavior.NextWave and nextDuration > 0:
			nextDuration -= 1
		if notifDuration < 1 and _spawningBehavior == spawningBehavior.Preparation:
			_change_spawning_state(spawningBehavior.Spawning)
	_update_ability_ui()
	wave_counter.text = "Waves Remaining: " + str(waves_remaining)
	score.text = "Score: " + str(PointSystemScript.playerScore)

	## Pause
	if Input.is_action_just_pressed("pause_action"):
		_pause_and_unpause_input()
	get_tree().paused = gamePaused == 1
#region ENEMY SPAWNING FUNCTION	

# spawns spawners
func _spawn_wave_spawners(spawnerCount: int) -> void:
	for i in range(spawnerCount):
		if spawner_scene == null:
			push_error("GManager: spawner_scene not assigned")
			return
		var spawner = spawner_scene.instantiate()
		spawner.visible = true
		#spawner.z_index = 0
		spawner.position = _get_random_spawn_position()
		spawner.rarityWeight = rarityWeight          
		spawner.final_wave = waves_remaining == 0   
		#if enemy_spawn_parent != null:
		add_child(spawner)#	enemy_spawn_parent.add_child(spawner)
		print("Spawned EnemySpawner ", i + 1, "/", spawner_count_per_wave)

func _is_inside_spawn_bounds(pos: Vector2) -> bool:
	if spawn_bounds == null:
		print("spawn bounds is missing")
		return true

	var local_pos := spawn_bounds.to_local(pos)

	return Geometry2D.is_point_in_polygon(
		local_pos,
		spawn_bounds.polygon
	)

func _get_random_spawn_position() -> Vector2:
	var attempts := 0

	while attempts < 30:
		var pos = Vector2(
			randf_range(-5074, 3241.0),
			randf_range(-1774.0, 5359.0)
		)

		## Must be inside polygon boundary
		if not _is_inside_spawn_bounds(pos):
			attempts += 1
			continue

		## Must not overlap obstacles/spawners
		if _is_position_clear(pos):
			return pos

		attempts += 1

	push_warning("GManager: fallback spawn used")
	return spawn_bounds.global_position

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
	match changeBehavior:
		spawningBehavior.Preparation:
			if waves_remaining == 0:
				wave_notification.text = "FINAL WAVE INCOMING!"
			else:
				wave_notification.text = "WAVE " + str(level_wave) + " INCOMING!"
		spawningBehavior.NextWave:
			if waves_remaining == 0:
				wave_notification.text = "BOSS DEFEATED!"
			else:
				wave_notification.text = "WAVE " + str(level_wave) + " COMPLETED!"
		spawningBehavior.Spawning:
			wave_notification.text = ""

	if changeBehavior == spawningBehavior.Spawning:
		time_since_spawning_started = 0.0
		if waves_remaining == 0:
			_spawn_boss()
		else:
			_spawn_wave_spawners(spawner_count_per_wave)

@onready var ability1_container: ColorRect = $InterfaceElements/NewHUD/UI/Ability1Container
@onready var rmb_container: ColorRect = $InterfaceElements/NewHUD/UI/RMBContainer

var _last_qmove_type: int = -1
var _last_secondary_size: int = -1

func _update_ability_ui() -> void:
	var player_node := player as PlayerCharacter
	if player_node == null:
		return

	## Only update if Q move type changed
	var current_qmove := int(player_node.q_moves.ability_type) if player_node.q_moves else -1
	if current_qmove != _last_qmove_type:
		_last_qmove_type = current_qmove
		if ability1_container:
			ability1_container.visible = (
				player_node.q_moves != null and
				player_node.q_moves.ability_type != QMoves.AbilityType.Q_NONE
			)

	## Only update if secondary actions changed
	var secondary := player_node.get_node_or_null("SecondaryFire")
	var current_secondary_size :int = secondary.secondary_actions.size() if secondary else 0
	if current_secondary_size != _last_secondary_size:
		_last_secondary_size = current_secondary_size
		if rmb_container:
			rmb_container.visible = current_secondary_size > 0

func _on_pause_screen_exit_game() -> void:
	get_tree().change_scene_to_file("res://Scenes/Interface/MainMenuScene.tscn")
	pass # Replace with function body.


func _on_pause_screen_resume_game() -> void:
	_resumeGame()
	pass # Replace with function body.


func _add_combo_level(strength_value: float) -> void:
	pass # Replace with function body.

func _exit_tree():
	cef.shutdown()
