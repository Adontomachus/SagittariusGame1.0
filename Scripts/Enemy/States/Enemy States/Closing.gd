class_name EnemyStateClosing
extends EnemyState

@export var after_closing_state: EnemyState



func enter() -> void:
	super()
	reposition(parent.aroundPlayerRadius)

func process_physics(delta: float) -> EnemyState:
	parent.move_enemy(delta)
	
	if parent.stamina <= 0:
		return recovery_state

	if parent.navAgent.is_navigation_finished() and after_closing_state:
		return after_closing_state

	return null

func reposition(playerRadius) -> void:
	if parent.target:
		var randomPosition = Vector2(randf_range(-playerRadius,playerRadius), randf_range(-playerRadius,playerRadius))
		parent.navAgent.target_position = parent.target.global_position + randomPosition
