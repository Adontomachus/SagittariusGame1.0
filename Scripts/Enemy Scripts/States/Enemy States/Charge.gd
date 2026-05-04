class_name EnemyStateCharge
extends EnemyState

@export var after_chase_state: EnemyState

func enter() -> void:
	super()

func process_physics(delta: float) -> EnemyState:
	parent.navAgent.target_position = parent.target.global_position
	
	parent.move_enemy(delta)
	
	if parent.stamina <= 0:
		return recovery_state

	if parent.navAgent.is_navigation_finished() and after_chase_state:
		return after_chase_state

	return null
