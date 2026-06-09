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
	time_before_expiration = start_time_before_expiration / parent.aggressiveness
	print("Companion Started!")
	reposition(parent.player_radius)	
	super()

	
func process_physics(delta: float) -> CompanionState:
	parent.move_companion(delta)
	time_before_expiration -= 1 * delta

	if time_before_expiration < 0 or parent.pathfinding.is_navigation_finished():
		## Scale attack chance by aggressiveness
		## aggressiveness 1.0 = uses successful_chance_to_attack as-is
		## aggressiveness 2.5 = threshold much lower = attacks far more often
		var roll := randf_range(CHANCE_TO_ATTACK.x, CHANCE_TO_ATTACK.y)
		var effective_threshold := successful_chance_to_attack / parent.aggressiveness
		print("Roll: ", roll, " | Threshold: ", effective_threshold, 
			  " | Aggressiveness: ", parent.aggressiveness,
			  " | nearest_enemy: ", parent.nearest_enemy)

		if roll >= effective_threshold:
			if attacking_state == null:
				push_error("CompanionStateFollowing: attacking_state is not assigned in inspector")
				return after_following_state
			print("Going to attack state")
			return attacking_state
		else:
			print("Going to after_following_state")
			return after_following_state

	return null

func reposition(playerRadius) -> void:
	if parent.player_target:
		var randomPosition = Vector2(randf_range(-playerRadius,playerRadius), randf_range(-playerRadius,playerRadius))
		parent.pathfinding.target_position = parent.player_target.global_position + randomPosition
