class_name GManager
extends Node2D

# For boss spawn checking
var boss_spawned: bool = false
var beat_sync: BeatSync_Script

@export_category("Boss Reward URLs")
@export var boss_reward_urls: Array[String] = []

@export_category("Enemy Spawner")
@export var spawner_scene: PackedScene = preload("res://UnitInstances/Enemy Instances/SpawnerEnemy.tscn")
@export var spawner_count_per_wave: int = 3

@export var beatIndicator: Panel
@export var player: Node2D

## For the combo system scoring methods
@onready var combo_system: ComboSystems = $GameSystems/ComboSystem
var player_combo_level: int
@export var enemy_spawn_parent: Node2D

# PAUSE UI
@onready var pause_screen: Control = $InterfaceElements/NewHUD/UI/PauseScreen
var gamePaused: int

@onready var spawn_bounds: CollisionPolygon2D = $"GameLevelNode/Stage1/EnemyNavRegion/Map Objects/MapEdgeObstacles/StaticBody2D/SpawnArea"

# LEVEL VARIABLES
var level_wave: int
var comboCount = 0
@export var waves_remaining: int
@export var player_target: Marker2D

#region SPAWNING VARIABLES AND STATS
const enemyToSpawn = preload("res://UnitInstances/Telegraphs/EnemySpawnWarning.tscn")
var playerSpawnDistance = 250
var shapeCast: ShapeCast2D
var enemySpawnWeightCounter: int
var rarityWeight: float
var rarityWeightIncrement: float = 0.5
@export var maxRarityValue: float
var enemySpawnCounter: int

# Cached enemy count — updated via signal or periodic poll
var enemyCount: int
var _enemy_count_dirty: bool = true
var _enemy_poll_timer: float = 0.0
const ENEMY_POLL_INTERVAL: float = 0.1

var waveCompleted: bool
#endregion

#region Signals Section
signal pulse_on_beat
signal scale_on_next_wave
#endregion

func start_game():
	player.camera.make_current()
	beat_sync = get_tree().get_first_node_in_group("BeatSync")
	beat_sync.start_game()

#region UI Elements
@onready var score: Label = $InterfaceElements/NewHUD/UI/PlayerInfo/Score
@onready var wave_counter: Label = $InterfaceElements/NewHUD/UI/PlayerInfo/WaveCounter
@onready var enemy_counter: Label = $InterfaceElements/NewHUD/UI/EnemyCounter
@onready var wave_notification: Label = $InterfaceElements/NewHUD/UI/WaveNotification

var notifDuration: float
var nextDuration: float

# Cache last label text to avoid redundant layout recalculations
var _last_score_text: String = ""
var _last_wave_text: String = ""
var _last_enemy_text: String = ""
#endregion

#region Enumerators
enum spawningBehavior {
	Preparation,
	Spawning,
	FinalAggressive,
	NextWave
}

@export var _spawningBehavior: spawningBehavior = spawningBehavior.Preparation
#endregion

var actualMousePosition: Vector2

@export var boss_scene: PackedScene = preload("res://UnitInstances/Enemy Instances/Boss.tscn")

func _spawn_boss() -> void:
	if boss_scene == null:
		push_error("GManager: boss_scene not assigned")
		return
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

	wave_notification.text = "FINAL WAVE — BOSS INCOMING!"

@onready var cef: GdCEF = $GdCEF

func _ready():
	wave_notification.self_modulate.a = 0
	pause_screen.visible = false
	gamePaused = 0

	world_parent = get_tree().current_scene.get_node_or_null(
		"GameLevelNode/Stage1/EnemyNavRegion/Map Objects/World"
	)
	var success := cef.initialize({})
	if !success:
		push_error(cef.get_error())
	else:
		print("CEF initialized!")

	get_viewport().physics_object_picking = true
	add_to_group("GManager")
	is_transitioning = false
	boss_spawned = false
	level_wave = 1
	rarityWeight = 3
	waveCompleted = false
	notifDuration = 6
	nextDuration = 6

	# Cache physics query objects to avoid per-spawn allocation
	_spawn_check_shape = CircleShape2D.new()
	_spawn_check_shape.radius = 60.0
	_spawn_query = PhysicsShapeQueryParameters2D.new()
	_spawn_query.shape = _spawn_check_shape
	_spawn_query.collision_mask = 0xFFFFFFFF
	_spawn_query.collide_with_bodies = true
	_spawn_query.collide_with_areas = false
	_spawn_transform = Transform2D()

	start_game()

#region TEMPORARY FUNCTIONS
func _next_wave(rarityIncrement) -> void:
	rarityWeight += rarityIncrement

func _finish_wave() -> void:
	pass

func _increaseIncrements() -> void:
	pass
#endregion

#region Pause Functions
func _resumeGame() -> void:
	gamePaused = 0
	get_tree().paused = false
	pause_screen.visible = false

func _exitGame() -> void:
	get_tree().change_scene_to_file("res://Scenes/Interface/MainMenuScene.tscn")

func _pauseGame() -> void:
	gamePaused = 1
	get_tree().paused = true
#endregion

func _on_resume_button_pressed() -> void:
	_resumeGame()

func _pause_and_unpause_input() -> void:
	if not get_tree().paused:
		pause_screen.visible = true
		_pauseGame()
	else:
		pause_screen.visible = false
		_resumeGame()

# SPAWNING
var randomNumber = randf_range(0, 1)
var playerRadius = 300
var instantiationPositions: Vector2
var spawning_grace_period: float = 3.0
var time_since_spawning_started: float = 0.0
var is_transitioning: bool = false

func _process(delta: float) -> void:
	if _spawningBehavior == spawningBehavior.Spawning:
		# Poll enemy count at a reduced rate instead of every frame
		_enemy_poll_timer += delta
		if _enemy_poll_timer >= ENEMY_POLL_INTERVAL or _enemy_count_dirty:
			_enemy_poll_timer = 0.0
			_enemy_count_dirty = false
			var new_count := get_tree().get_nodes_in_group("GeneralEnemyInstance").size()
			if new_count != enemyCount:
				enemyCount = new_count
				var new_text := "Enemies Left: " + str(enemyCount)
				if enemy_counter.text != new_text:
					enemy_counter.text = new_text

		time_since_spawning_started += delta
		# Fade out notification
		wave_notification.self_modulate.a = maxf(wave_notification.self_modulate.a - delta * 2.0, 0.0)
		# Wave completion check
		if time_since_spawning_started >= spawning_grace_period and enemyCount == 0:
			_change_spawning_state(spawningBehavior.NextWave)

	if _spawningBehavior == spawningBehavior.Preparation and not is_transitioning:
		wave_notification.self_modulate.a = minf(wave_notification.self_modulate.a + delta, 1.0)

	if _spawningBehavior == spawningBehavior.NextWave:
		if nextDuration >= 1:
			wave_notification.self_modulate.a = minf(wave_notification.self_modulate.a + delta, 1.0)
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

	# Only update labels when text changes
	var new_wave_text := "Waves Remaining: " + str(waves_remaining)
	if wave_counter.text != new_wave_text:
		wave_counter.text = new_wave_text
	var new_score_text := "Score: " + str(PointSystemScript.playerScore)
	if score.text != new_score_text:
		score.text = new_score_text

	# Pause
	if Input.is_action_just_pressed("pause_action"):
		_pause_and_unpause_input()
	get_tree().paused = gamePaused == 1

#region ENEMY SPAWNING
var world_parent: Node2D

# Cached physics objects (allocated once in _ready)
var _spawn_check_shape: CircleShape2D
var _spawn_query: PhysicsShapeQueryParameters2D
var _spawn_transform: Transform2D

func _spawn_wave_spawners(spawnerCount: int) -> void:
	if spawner_scene == null:
		push_error("GManager: spawner_scene not assigned")
		return
	for i in range(spawnerCount):
		var spawner = spawner_scene.instantiate()
		spawner.visible = true
		spawner.position = _get_random_spawn_position()
		spawner.rarityWeight = rarityWeight
		spawner.final_wave = waves_remaining == 0
		world_parent.add_child(spawner)
		print("Spawned EnemySpawner ", i + 1, "/", spawner_count_per_wave)

func _is_inside_spawn_bounds(pos: Vector2) -> bool:
	if spawn_bounds == null:
		push_warning("spawn bounds is missing")
		return true
	var local_pos := spawn_bounds.to_local(pos)
	return Geometry2D.is_point_in_polygon(local_pos, spawn_bounds.polygon)

func _get_random_spawn_position() -> Vector2:
	var attempts := 0
	while attempts < 30:
		var pos = Vector2(
			randf_range(-5074, 3241.0),
			randf_range(-1774.0, 5359.0)
		)
		if not _is_inside_spawn_bounds(pos):
			attempts += 1
			continue
		if _is_position_clear(pos):
			return pos
		attempts += 1
	push_warning("GManager: fallback spawn used")
	return spawn_bounds.global_position

func _is_position_clear(pos: Vector2) -> bool:
	_spawn_transform.origin = pos
	_spawn_query.transform = _spawn_transform
	var results := get_world_2d().direct_space_state.intersect_shape(_spawn_query)
	for result in results:
		var collider = result.collider
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

@onready var ability1_container: TextureRect = $InterfaceElements/NewHUD/UI/QContainer4/TextureRect
@onready var rmb_container: TextureRect = $InterfaceElements/NewHUD/UI/RMBContainer/TextureRect

var _last_qmove_type: int = -1
var _last_secondary_size: int = -1

func _update_ability_ui() -> void:
	var player_node := player as PlayerCharacter
	if player_node == null:
		return
	var current_qmove := int(player_node.q_moves.ability_type) if player_node.q_moves else -1
	if current_qmove != _last_qmove_type:
		_last_qmove_type = current_qmove
		if ability1_container:
			ability1_container.visible = (
				player_node.q_moves != null and
				player_node.q_moves.ability_type != QMoves.AbilityType.Q_NONE
			)
			if player_node.q_moves and player_node.q_moves.equipped_upgrade:
				ability1_container.texture = player_node.q_moves.equipped_upgrade.icon
				## Force square aspect and fill parent
				ability1_container.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
				ability1_container.stretch_mode = TextureRect.STRETCH_SCALE

	var secondary := player_node.get_node_or_null("SecondaryFire")
	var current_secondary_size: int = secondary.secondary_actions.size() if secondary else 0
	if current_secondary_size != _last_secondary_size:
		_last_secondary_size = current_secondary_size
		if rmb_container:
			rmb_container.visible = current_secondary_size > 0
			if secondary and secondary.equipped_upgrade:
				rmb_container.texture = secondary.equipped_upgrade.icon
				## Force square aspect and fill parent
				rmb_container.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
				rmb_container.stretch_mode = TextureRect.STRETCH_SCALE

func _on_pause_screen_exit_game() -> void:
	get_tree().change_scene_to_file("res://Scenes/Interface/MainMenuScene.tscn")

func _on_pause_screen_resume_game() -> void:
	_resumeGame()

func _add_combo_level(strength_value: float) -> void:
	pass

func _exit_tree() -> void:
	cef.shutdown()

## Call this from enemy scripts when they die for instant count updates
## (fallback polling at 10Hz still runs if not connected)
func _on_enemy_died() -> void:
	_enemy_count_dirty = true
