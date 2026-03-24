class_name CompanionStateFollowing
extends CompanionState

@export var after_position_state: CompanionState



func enter() -> void:
	super()
	reposition(parent.player_radius)
	
func process_physics(delta: float) -> CompanionState:
	#parent.move_companion(delta)



	#if parent.pathfinding.is_navigation_finished() and after_position_state:
	#	return after_position_state

	#if parent.repositioningTimer < 0:
	#	parent.repositioningTimer = parent.maxRepositioningTimer
	#	reposition(parent.aroundPlayerRadius)

	#region TESTING	
	print("Testing!")
	var targetLocation = parent.pathfinding.get_next_path_position()
	var new_velocity = parent.global_position.direction_to(targetLocation) * parent.currentMoveSpeed
	
	parent.velocity = parent.new_velocity
	
	if (parent.pathfinding.avoidance_enabled):
		parent.pathfinding.set_velocity(new_velocity)

	parent.move_and_slide()
	#endregion
	return null

func reposition(playerRadius) -> void:
	if parent.player_target:
		var randomPosition = Vector2(randf_range(-playerRadius,playerRadius), randf_range(-playerRadius,playerRadius))
		parent.pathfinding.target_position = parent.player_target.global_position + randomPosition
