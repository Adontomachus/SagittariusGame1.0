class_name EnemyStateBossRecovery
extends EnemyState

@export var state_to_return: EnemyState
@export var summoning_state: EnemyState

func process_physics(delta: float) -> EnemyState:
	if parent.recovery_mode(delta):
		return summoning_state

	return null
