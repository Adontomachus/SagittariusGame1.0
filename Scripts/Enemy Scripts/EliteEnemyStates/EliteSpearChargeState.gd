class_name EliteSpearChargeState
extends EnemyState

@export var rest_state: EliteSpearRestState
@export var charge_beats: int = 3

var beats_elapsed: int = 0
var last_beat: float = 0.0
var telegraph: SpearTelegraph


func enter() -> void:
	super()
	beats_elapsed = 0
	last_beat = beat_sync.beat if beat_sync else 0.0

	## Spawn or get telegraph
	telegraph = _get_or_create_telegraph()
	telegraph.show_charging()


func process_frame(_delta: float) -> EnemyState:
	if beat_sync == null or parent.target == null:
		return null

	## Telegraph follows player while charging
	telegraph.track_player(parent.global_position, parent.target.global_position)

	var current_beat := beat_sync.beat
	if current_beat > last_beat:
		last_beat = current_beat
		beats_elapsed += 1
		if beats_elapsed >= charge_beats:
			## Pass telegraph to rest state so it keeps the locked direction
			rest_state.telegraph = telegraph
			rest_state.locked_direction = (parent.target.global_position - parent.global_position).normalized()
			return rest_state

	return null


func exit() -> void:
	pass


func _get_or_create_telegraph() -> SpearTelegraph:
	var existing := parent.get_node_or_null("SpearTelegraph")
	if existing:
		return existing
	var t := preload("res://Objects/Instances With Collision/SpearTelegraph.tscn").instantiate()
	t.name = "SpearTelegraph"
	parent.add_child(t)
	return t
