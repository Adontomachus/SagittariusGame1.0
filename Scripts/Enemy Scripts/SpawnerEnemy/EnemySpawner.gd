class_name EnemySpawner
extends Enemy

@export_category("Spawner Settings")
@export var max_spawn_count: int = 40
@export var beats_between_spawns: int = 2
@export var spawn_radius: float = 150.0
@export var rarityWeight: float = 3.0
@export var final_wave: bool = false

@export_category("Enemy Scenes")
@export var enemyToSpawn: PackedScene = preload("res://UnitInstances/Enemy Instances/Enemy.tscn")
@export var altEnemy: PackedScene = preload("res://UnitInstances/Enemy Instances/EnemyShooter.tscn")
@export var eliteEnemy: PackedScene = preload("res://UnitInstances/Enemy Instances/EliteEnemy.tscn")
@export var chargerEnemy: PackedScene = preload("res://UnitInstances/Enemy Instances/EnemyCharger.tscn")
@export var bossSpawn: PackedScene = preload("res://UnitInstances/Enemy Instances/Boss.tscn")
@export var stationaryEnemy: PackedScene = preload("res://UnitInstances/Enemy Instances/StationaryEnemy.tscn")

@export_category("Spawner Visuals")
@export var spawner_sprite: Sprite2D
@export var spawn_indicator: Sprite2D

const CHANCE_RANGE: Vector2 = Vector2(0, 10)

var spawned_count: int = 0
var beats_elapsed: int = 0
var last_beat: float = 0.0
var beat_sync: BeatSync_Script
var is_active: bool = true
var tween: Tween


func _ready() -> void:
	super()
	add_to_group("GeneralEnemyInstance")
	beat_sync = get_tree().get_first_node_in_group("BeatSync")
	if beat_sync == null:
		push_error("EnemySpawner: BeatSync not found")


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

	var spawn_pos := _get_spawn_position()
	var enemy_scene := _pick_enemy_type()

	if enemy_scene == null:
		push_error("EnemySpawner: no valid enemy scene to spawn")
		return

	var enemy = enemy_scene.instantiate()
	get_tree().current_scene.add_child(enemy)
	enemy.global_position = spawn_pos
	spawned_count += 1
	print("EnemySpawner spawned: ", enemy.name, " (", spawned_count, "/", max_spawn_count, ")")


func _pick_enemy_type() -> PackedScene:
	if final_wave:
		return bossSpawn

	var eliteRarityWeight := rarityWeight - 3.0

	if randf_range(CHANCE_RANGE.x, CHANCE_RANGE.y) <= rarityWeight - 4:
		return chargerEnemy
	elif randf_range(CHANCE_RANGE.x, CHANCE_RANGE.y) <= eliteRarityWeight:
		return eliteEnemy
	elif randf_range(CHANCE_RANGE.x, CHANCE_RANGE.y) <= rarityWeight - 1.5:
		return stationaryEnemy
	elif randf_range(CHANCE_RANGE.x, CHANCE_RANGE.y) <= rarityWeight:
		return altEnemy
	else:
		return enemyToSpawn


func _get_spawn_position() -> Vector2:
	var angle := randf() * TAU
	var distance := randf_range(spawn_radius * 0.3, spawn_radius)
	return global_position + Vector2(cos(angle), sin(angle)) * distance


func modify_health(increment: int) -> void:
	super(increment)
	if baseHealthPoints <= 0:
		is_active = false
