class_name CompanionStateFollowing
extends CompanionState

@export var after_position_state: CompanionState



func enter() -> void:
	print("Companion Started!")
	reposition(parent.player_radius)
	super()

	
func process_physics(delta: float) -> CompanionState:
	var randomPosition = Vector2(randf_range(-parent.player_radius,parent.player_radius), randf_range(-parent.player_radius,parent.player_radius))
	parent.pathfinding.target_position = parent.player_target.global_position # + randomPosition
	reposition(parent.player_radius)
	parent.move_companion(delta)
	


	if parent.pathfinding.is_navigation_finished() and after_position_state:
		return after_position_state
	return null

func reposition(playerRadius) -> void:
	if parent.player_target:
		var randomPosition = Vector2(randf_range(-playerRadius,playerRadius), randf_range(-playerRadius,playerRadius))
		parent.pathfinding.target_position = parent.player_target.global_position + randomPosition
