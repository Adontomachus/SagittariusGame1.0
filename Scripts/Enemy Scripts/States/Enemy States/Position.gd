class_name EnemyStatePositioning
extends EnemyState

@export var after_position_state: EnemyState
@export var attack_state: EnemyState
@export var successful_chance_to_attack: float
const CHANCE_TO_ATTACK: Vector2 = Vector2(0.0, 5.0)

func enter() -> void:
	super()
	reposition(parent.aroundPlayerRadius)
	
func process_physics(delta: float) -> EnemyState:
	parent.move_enemy(delta)

	parent.repositioningTimer -= 8 * delta
	
	if parent.stamina <= 0:
		return recovery_state

	if parent.navAgent.is_navigation_finished() and after_position_state:
		if randf_range(CHANCE_TO_ATTACK.x, CHANCE_TO_ATTACK.y) >= successful_chance_to_attack:
			return attack_state
		else:
			return after_position_state

	if parent.repositioningTimer < 0:
		parent.repositioningTimer = parent.maxRepositioningTimer
		reposition(parent.aroundPlayerRadius)

	return null

func reposition(playerRadius) -> void:
	if parent.target:
		var randomPosition = Vector2(randf_range(-playerRadius,playerRadius), randf_range(-playerRadius,playerRadius))
		parent.navAgent.target_position = parent.target.global_position + randomPosition
