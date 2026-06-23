class_name EnemyStateStrafing
extends EnemyState

@export var after_strafing_state: EnemyState

# Shooting Chances
const CHANCE_RANGE: Vector2 = Vector2(0.0, 10.0)
var can_move = 1
var shot_times: int = 0

# Attack Point
@onready var attack_point: Marker2D = $"../../MovementStretch/Sprite/AttackPoint"

func enter() -> void:
	super()
	_check_difficulty()
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
		if randf_range(CHANCE_RANGE.x, CHANCE_RANGE.y) >= parent.successfulChanceToAttack:
			shot_times += 1
			
		if shot_times >= 2:
			shot_times = 0
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


func _check_difficulty() -> void:
	var difficulty_settings = SaveSettings._load_difficulty_settings()
	match difficulty_settings:
		0:
			parent.successfulChanceToAttack = 7.5
		1:
			parent.successfulChanceToAttack = 5
		2:
			parent.successfulChanceToAttack = 0.5
	return
