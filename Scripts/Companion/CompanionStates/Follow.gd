class_name CompanionStateFollowing
extends CompanionState

@export var after_following_state: CompanionState
## Variables for attacking state
@export var attacking_state: CompanionState
@export var successful_chance_to_attack: float
const CHANCE_TO_ATTACK: Vector2 = Vector2(0.0, 5.0)

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
#	reposition(parent.player_radius)
	parent.move_companion(delta)
		
	#if GlobalBeatSync.lastBeat < GlobalBeatSync.beat:
	print("Notes before resting: ", time_before_expiration)
	time_before_expiration -= 1 * delta
	if time_before_expiration < 0 or parent.pathfinding.is_navigation_finished():
		if randf_range(CHANCE_TO_ATTACK.x, CHANCE_TO_ATTACK.y) >= successful_chance_to_attack:
			return attacking_state
		else:
			return after_following_state
	
	#if parent.pathfinding.is_navidgastion_finished() and after_following_state:
	#	return after_following_state
	#await get_tree().create_timer(time_before_expiration).timeout
	return

func reposition(playerRadius) -> void:
	if parent.player_target:
		var randomPosition = Vector2(randf_range(-playerRadius,playerRadius), randf_range(-playerRadius,playerRadius))
		parent.pathfinding.target_position = parent.player_target.global_position + randomPosition
