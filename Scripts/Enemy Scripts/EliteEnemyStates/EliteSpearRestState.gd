class_name EliteSpearRestState
extends EnemyState

@export var fire_state: EliteSpearFireState
@export var return_state: EnemyState  ## state to return to after firing 

var beats_elapsed: int = 0
var last_beat: float = 0.0
var telegraph: SpearTelegraph
var locked_direction: Vector2 = Vector2.RIGHT


func enter() -> void:
	super()
	beats_elapsed = 0
	last_beat = beat_sync.beat if beat_sync else 0.0

	## Freeze telegraph in place
	if telegraph:
		telegraph.show_locked()


func process_frame(_delta: float) -> EnemyState:
	if beat_sync == null:
		return null

	var current_beat := beat_sync.beat
	if current_beat > last_beat:
		last_beat = current_beat
		beats_elapsed += 1
		if beats_elapsed >= 1:
			## Pass data to fire state
			fire_state.telegraph = telegraph
			fire_state.fire_direction = locked_direction
			fire_state.return_state = return_state
			return fire_state

	return null


func exit() -> void:
	pass
