class_name EnemyStateBarrage
extends EnemyState

@export var after_strafing_state: EnemyState
@export var successful_chance_to_attack: float

# Shooting Chances
const CHANCE_RANGE: Vector2 = Vector2(0.0, 10.0)
var can_move = 1
var shot_times: int = 0

func enter() -> void:
	super()
	reposition(parent.aroundPlayerRadius)
	
func process_physics(delta: float) -> EnemyState:
	if can_move == 1:
		#strafe(parent.aroundPlayerRadius)
		can_move = 0
	# parent.navAgent.target_position = parent.target.global_position
	parent.move_enemy(delta)
	parent.repositioningTimer -= 6 * delta
	
	if parent.stamina <= 0:
		return recovery_state
	
	# Shoot on beat
	if (GlobalBeatSync.executeAction):
		shot_times += 1
		if randf_range(CHANCE_RANGE.x, CHANCE_RANGE.y) >= successful_chance_to_attack:
			parent.shoot_projectile()
			
	if parent.navAgent.is_navigation_finished() and after_strafing_state:
		return after_strafing_state

	return null
#func strafe(playerRadius):
#	if parent.target:
#		var randomPosition = Vector2(randf_range(-playerRadius,playerRadius), randf_range(-playerRadius,playerRadius))
#		parent.navAgent.target_position = parent.target.global_position + randomPosition
#	pass
func reposition(playerRadius) -> void:
	if parent.target:
		var randomPosition = Vector2(randf_range(-playerRadius,playerRadius), randf_range(-playerRadius,playerRadius))
		parent.navAgent.target_position = parent.target.global_position + randomPosition
