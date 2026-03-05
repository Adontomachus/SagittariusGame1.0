class_name EnemyStateTurretFire
extends EnemyState

@export var state_to_return: EnemyState

func process_physics(delta: float) -> EnemyState:
	#if parent.recovery_mode(delta):
		#return state_to_return

	return null
