class_name EnemyStateTurretFire
extends EnemyState

@export var state_to_return: EnemyState
const CHANCE_RANGE: Vector2 = Vector2(0.0, 10.0)
var shot_times: int = 0
@export var attack_range: float = 600

func enter() -> void:
	super()
	shot_times = 0

func process_physics(delta: float) -> EnemyState:
	if (GlobalBeatSync.executeAction):
		shot_times += 1
		if randf_range(CHANCE_RANGE.x, CHANCE_RANGE.y) >= parent.successfulChanceToAttack:
			for shot in range(6):
				parent.shoot_projectile()

	#if parent.recovery_mode(delta):
		#return state_to_return

	return null
