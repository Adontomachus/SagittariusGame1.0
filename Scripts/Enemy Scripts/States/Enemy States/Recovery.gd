class_name EnemyStateRecovery
extends EnemyState

@export var state_to_return: EnemyState


func enter() -> void:
	super()
	parent.velocity = Vector2.ZERO


func process_physics(delta: float) -> EnemyState:
	parent.velocity = Vector2.ZERO

	if parent.recovery_mode(delta):
		return state_to_return
	return null
