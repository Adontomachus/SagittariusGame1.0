class_name CompanionStateStationary
extends CompanionState

@export var returning_state: CompanionState

@export var starting_rest_duration: float = 3
var rest_duration: float


func enter() -> void:
	reposition(parent.player_radius)
	rest_duration = starting_rest_duration 

func process_physics(delta: float) -> CompanionState:
	rest_duration -= 1 * delta
	if rest_duration < 0:
		return returning_state
	return null
	
func reposition(playerRadius) -> void:
	if parent.player_target:
		var randomPosition = Vector2(randf_range(-playerRadius,playerRadius), randf_range(-playerRadius,playerRadius))
		parent.pathfinding.target_position = parent.player_target.global_position + randomPosition
