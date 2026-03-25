class_name CompanionStateFollowing
extends CompanionState

@export var after_position_state: CompanionState



func enter() -> void:
	super()
	reposition(parent.player_radius)
	
func process_physics(delta: float) -> CompanionState:
	parent.pathfinding.target_position = parent.player_target.global_position
	
	parent.move_companion(delta)
	


	if parent.pathfinding.is_navigation_finished() and after_position_state:
		return after_position_state
	return null

func reposition(playerRadius) -> void:
	if parent.player_target:
		var randomPosition = Vector2(randf_range(-playerRadius,playerRadius), randf_range(-playerRadius,playerRadius))
		parent.pathfinding.target_position = parent.player_target.global_position + randomPosition
