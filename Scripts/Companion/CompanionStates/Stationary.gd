class_name CompanionStateStationary
extends CompanionState

@export var returning_state: CompanionState

@export var starting_rest_duration: float = 3
var rest_duration: float


func enter() -> void:
	rest_duration = starting_rest_duration / parent.aggressiveness

func process_physics(delta: float) -> CompanionState:
	rest_duration -= 1 * delta
	if rest_duration < 0:
		return returning_state
	return null
