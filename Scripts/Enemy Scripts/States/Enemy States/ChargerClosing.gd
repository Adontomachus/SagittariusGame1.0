class_name EnemyStateChargerClosing
extends EnemyState


@export var after_closing_state: EnemyState
@export var windup_state: EnemyState
@export var can_charge_player: bool = true
@export var charge_cooldown: float = 8
@export var max_charge_cooldown: float = 8

const CHANCE_RANGE: Vector2 = Vector2(0.0, 10.0)
@export var successful_chance_range: float

func enter() -> void:
	super()
	reposition()

func process_physics(delta: float) -> EnemyState:
	charge_cooldown += 1 * delta
	parent.move_enemy(delta)
	#if parent.stamina <= 0:
	#	return recovery_state
	if parent.navAgent.is_navigation_finished() or parent.stamina <= 0: # and after_closing_state:
		if charge_cooldown > max_charge_cooldown:
			if randf_range(CHANCE_RANGE.x, CHANCE_RANGE.y) >= successful_chance_range:
				charge_cooldown = 0
				return windup_state
			else:
				return recovery_state
	return null

func reposition() -> void:
	if parent.target:
		var randomPosition = Vector2(randf_range(-parent.aroundPlayerRadius,parent.aroundPlayerRadius), randf_range(-parent.aroundPlayerRadius,parent.aroundPlayerRadius))
		parent.navAgent.target_position = parent.target.global_position + randomPosition
