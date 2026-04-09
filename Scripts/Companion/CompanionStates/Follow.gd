class_name CompanionStateFollowing
extends CompanionState

@export var after_following_state: CompanionState
@export var start_time_before_expiration: float
var time_before_expiration: float

func enter() -> void:
	time_before_expiration = start_time_before_expiration

	print("Companion Started!")
	reposition(parent.player_radius)
	super()

	
func process_physics(delta: float) -> CompanionState:
#	var randomPosition = Vector2(randf_range(-parent.player_radius,parent.player_radius), randf_range(-parent.player_radius,parent.player_radius))
#	parent.pathfinding.target_position = parent.player_target.global_position # + randomPosition
	reposition(parent.player_radius)
	parent.move_companion(delta)
	
	time_before_expiration -= 1 * delta
	if time_before_expiration < 0:
		return after_following_state

	if parent.pathfinding.is_navigation_finished() and after_following_state:
		return after_following_state
	#await get_tree().create_timer(time_before_expiration).timeout
	return

func reposition(playerRadius) -> void:
	if parent.player_target:
		var randomPosition = Vector2(randf_range(-playerRadius,playerRadius), randf_range(-playerRadius,playerRadius))
		parent.pathfinding.target_position = parent.player_target.global_position + randomPosition
