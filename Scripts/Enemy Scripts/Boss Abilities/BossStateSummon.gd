class_name BossStateSummon
extends EnemyState

@export var next_state: EnemyState

@export_category("Summon Settings")
@export var enemies_to_summon: int = 4
@export var beats_between_summons: int = 1
@export var summon_radius: float = 250.0

var summoned_count: int = 0
var beats_elapsed: int = 0
var last_beat: float = 0.0

var enemy_scene := preload("res://UnitInstances/Enemy Instances/Enemy.tscn")
var spawn_indicator_scene := preload("res://UnitInstances/Enemy Instances/SpawnIndicator.tscn")


func enter() -> void:
	super()
	summoned_count = 0
	beats_elapsed = 0
	last_beat = beat_sync.beat if beat_sync else 0.0


func process_frame(_delta: float) -> EnemyState:
	if beat_sync == null:
		return null

	var current_beat := beat_sync.beat
	if current_beat > last_beat:
		last_beat = current_beat
		beats_elapsed += 1

		if beats_elapsed >= beats_between_summons:
			beats_elapsed = 0
			_summon_enemy()
			summoned_count += 1

			if summoned_count >= enemies_to_summon:
				return next_state

	return null


func _summon_enemy() -> void:
	var spawn_pos := _get_valid_spawn_position()
	if spawn_pos == Vector2.INF:
		push_warning("BossStateSummon: could not find valid spawn position")
		return

	## Use spawn indicator for visual flair
	if spawn_indicator_scene:
		var indicator = spawn_indicator_scene.instantiate()
		get_tree().current_scene.add_child(indicator)
		indicator.global_position = spawn_pos
		_spawn_with_indicator.call_deferred(indicator, spawn_pos)
	else:
		var enemy = enemy_scene.instantiate()
		get_tree().current_scene.add_child(enemy)
		enemy.global_position = spawn_pos


func _spawn_with_indicator(indicator: Node, spawn_pos: Vector2) -> void:
	await indicator.play_and_spawn(enemy_scene, spawn_pos)


func _get_valid_spawn_position() -> Vector2:
	var space := parent.get_world_2d().direct_space_state
	var attempts := 0

	while attempts < 15:
		var angle := randf() * TAU
		var distance := randf_range(summon_radius * 0.3, summon_radius)
		var pos := parent.global_position + Vector2(cos(angle), sin(angle)) * distance

		## Check clear using shape query
		var shape := CircleShape2D.new()
		shape.radius = 40.0
		var query := PhysicsShapeQueryParameters2D.new()
		query.shape = shape
		query.transform = Transform2D(0, pos)
		query.collide_with_bodies = true
		var results := space.intersect_shape(query)

		var blocked := false
		for result in results:
			if result.collider.is_in_group("MapObstacle"):
				blocked = true
				break
		if not blocked:
			return pos
		attempts += 1

	return Vector2.INF


func exit() -> void:
	pass
