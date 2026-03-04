class_name EnemyStateStrafing
extends EnemyState

@export var after_strafing_state: EnemyState

#Shooting Chances
const CHANCE_RANGE: Vector2 = Vector2(0.0, 10.0)

var shot_times: int = 0

func enter() -> void:
	super()
	strafe()

func process_physics(delta: float) -> EnemyState:
	
	parent.move_enemy(delta)
	
	if parent.stamina <= 0:
		return recovery_state
	if parent.navAgent.is_navigation_finished() and after_strafing_state:
		return after_strafing_state

	return null
	
func strafe() -> void:
	if parent.target:
		#var randomPosition = Vector2(randf_range(-playerRadius,playerRadius), randf_range(-playerRadius,playerRadius))
		parent.navAgent.target_position = parent.target.global_position
