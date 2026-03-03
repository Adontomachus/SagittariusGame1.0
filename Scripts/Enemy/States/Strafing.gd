class_name EnemyStateStrafing
extends EnemyState

@export var after_strafing_state: EnemyState
@export var randomness_to_target: float

func enter() -> void:
	super()

func process_physics(delta: float) -> EnemyState:
	parent.navAgent.target_position = parent.target.global_position
	
	parent.move_enemy(delta)
	
	if parent.stamina <= 0:
		return recovery_state

	if parent.navAgent.is_navigation_finished() and after_strafing_state:
		return after_strafing_state

	return null
