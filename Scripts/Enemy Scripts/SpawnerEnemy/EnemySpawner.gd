class_name EnemySpawner
extends Enemy

@export_category("Spawner Settings")
@export var max_spawn_count: int = 40
@export var beats_between_spawns: int = 2
@export var spawn_radius: float = 10.0
@export var rarityWeight: float = 3.0
@export var final_wave: bool = false

@export_category("Enemy Scenes")
@export var enemyToSpawn: PackedScene = preload("res://UnitInstances/Enemy Instances/Enemy.tscn")
@export var altEnemy: PackedScene = preload("res://UnitInstances/Enemy Instances/EnemyShooter.tscn")
@export var eliteEnemy: PackedScene = preload("res://UnitInstances/Enemy Instances/EliteEnemy.tscn")
@export var chargerEnemy: PackedScene = preload("res://UnitInstances/Enemy Instances/EnemyCharger.tscn")
@export var bossSpawn: PackedScene = preload("res://UnitInstances/Enemy Instances/Boss.tscn")
@export var stationaryEnemy: PackedScene = preload("res://UnitInstances/Enemy Instances/StationaryEnemy.tscn")
@export var spawn_indicator_scene: PackedScene = preload("res://UnitInstances/Enemy Instances/SpawnIndicator.tscn")

@export_category("Spawner Visuals")
@export var spawner_sprite: Sprite2D
@export var spawn_indicator: Sprite2D

@onready var spawn_noise: AudioStreamPlayer = $SpawnSound

const CHANCE_RANGE: Vector2 = Vector2(0, 10)

var spawned_count: int = 0
var beats_elapsed: int = 0
var last_beat: float = 0.0
var beat_sync: BeatSync_Script
var is_active: bool = true
var tween: Tween

var world_parent: Node2D

#region Cached Physics Objects
var _spawn_check_shape: CircleShape2D
var _spawn_query: PhysicsShapeQueryParameters2D
var _spawn_transform: Transform2D
#endregion

#region Cached Rarity Thresholds
var _charger_threshold: float
var _elite_threshold: float
var _stationary_threshold: float
var _alt_threshold: float
#endregion

func _ready() -> void:
	super()
	allow_sprite_flip = false
	self.visible = true
	add_to_group("GeneralEnemyInstance")
	beat_sync = get_tree().get_first_node_in_group("BeatSync")
	if beat_sync == null:
		push_error("EnemySpawner: BeatSync not found")
	if spawner_sprite:
		spawner_sprite.material = null
	if state_machine and state_machine.sprite:
		state_machine.sprite.material = null

	world_parent = get_tree().current_scene.get_node_or_null(
		"GameLevelNode/Stage1/EnemyNavRegion/Map Objects/World"
	)
	if world_parent == null:
		push_error("EnemySpawner: could not find World node at expected path")
	else:
		print("EnemySpawner found World parent: ", world_parent.name, " | Y Sort Enabled: ", world_parent.y_sort_enabled)

	# Cache physics query objects (avoid per-spawn allocation)
	_spawn_check_shape = CircleShape2D.new()
	_spawn_check_shape.radius = 40.0
	_spawn_query = PhysicsShapeQueryParameters2D.new()
	_spawn_query.shape = _spawn_check_shape
	_spawn_query.collision_mask = 0xFFFFFFFF
	_spawn_query.collide_with_bodies = true
	_spawn_query.collide_with_areas = false
	_spawn_transform = Transform2D()

	# Pre-calculate rarity thresholds
	_update_rarity_thresholds()

func _update_rarity_thresholds() -> void:
	var eliteRarityWeight := rarityWeight - 3.0
	_charger_threshold = rarityWeight - 4.0
	_elite_threshold = eliteRarityWeight
	_stationary_threshold = rarityWeight - 1.5
	_alt_threshold = rarityWeight

func _process(_delta: float) -> void:
	if not is_active or beat_sync == null:
		return
	var current_beat := beat_sync.beat
	if current_beat > last_beat:
		last_beat = current_beat
		beats_elapsed += 1
		if beats_elapsed >= beats_between_spawns:
			beats_elapsed = 0
			_try_spawn()

func _try_spawn() -> void:
	if spawned_count >= max_spawn_count:
		return
	if world_parent == null:
		push_error("EnemySpawner: world_parent is null, cannot spawn")
		return
	var spawn_pos := _get_spawn_position()
	var enemy_scene := _pick_enemy_type()
	if enemy_scene == null:
		push_error("EnemySpawner: no valid enemy scene to spawn")
		return
	spawned_count += 1
	spawn_noise.play()
	if spawn_indicator_scene:
		var indicator = spawn_indicator_scene.instantiate()
		indicator.z_index = 999
		indicator.z_as_relative = false
		world_parent.add_child(indicator)
		indicator.global_position = spawn_pos
		await get_tree().process_frame
		await indicator.play_and_spawn(enemy_scene, spawn_pos)
	else:
		var enemy = enemy_scene.instantiate()
		world_parent.add_child(enemy)
		enemy.global_position = spawn_pos
	print("EnemySpawner queued spawn ", spawned_count, "/", max_spawn_count)

func _pick_enemy_type() -> PackedScene:
	## Single roll instead of 4 separate randf_range calls
	var roll := randf_range(CHANCE_RANGE.x, CHANCE_RANGE.y)
	if roll <= _charger_threshold:
		return chargerEnemy
	elif roll <= _elite_threshold:
		return eliteEnemy
	elif roll <= _stationary_threshold:
		return stationaryEnemy
	elif roll <= _alt_threshold:
		return altEnemy
	else:
		return enemyToSpawn

func _get_spawn_position() -> Vector2:
	var space := get_world_2d().direct_space_state
	var attempts := 0

	while attempts < 15:
		var angle := randf() * TAU
		var distance := randf_range(spawn_radius * 0.3, spawn_radius)
		var pos := global_position + Vector2(cos(angle), sin(angle)) * distance

		## Reuse cached query objects
		_spawn_transform.origin = pos
		_spawn_query.transform = _spawn_transform
		_spawn_query.exclude = [get_rid()]

		var results := space.intersect_shape(_spawn_query)

		var blocked := false
		for result in results:
			var collider = result.collider
			if collider.is_in_group("MapObstacle") or collider.is_in_group("GeneralEnemyInstance"):
				blocked = true
				break

		if not blocked:
			return pos

		attempts += 1

	## Fallback
	push_warning("EnemySpawner: could not find clear spot, using fallback position")
	var fallback_angle := randf() * TAU
	return global_position + Vector2(cos(fallback_angle), sin(fallback_angle)) * spawn_radius

func modify_health(increment: int) -> void:
	super(increment)
	if baseHealthPoints <= 0:
		is_active = false
		## Balete Heart — heal player when spawner is cleared
		var player := get_tree().get_first_node_in_group("PlayerObject") as PlayerCharacter
		if player and player.balete_heart:
			var heal_amount := int(player.maxHealthPoints * 0.08)
			player.modify_current_player_health(heal_amount)
			print("Balete Heart healed player for: ", heal_amount)
