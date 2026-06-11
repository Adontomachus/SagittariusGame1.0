class_name BossStatePositioning
extends EnemyState

@export var decide_state: BossStateDecide
@export var successful_chance_to_attack: float = 2.0

const CHANCE_TO_ATTACK: Vector2 = Vector2(0.0, 5.0)

## Boss repositions further away than regular enemies
@export var positioning_radius: float = 20


func enter() -> void:
	super()
	reposition()


func process_physics(delta: float) -> EnemyState:
	parent.move_enemy(delta)
	parent.repositioningTimer -= 8 * delta

	#if parent.stamina <= 0:
		#return recovery_state

	## Once navigation finishes, decide whether to attack or reposition again
	if parent.navAgent.is_navigation_finished():
		if randf_range(CHANCE_TO_ATTACK.x, CHANCE_TO_ATTACK.y) >= successful_chance_to_attack:
			return decide_state
		#else:
			#reposition()
#
	### Reposition timer expired — Deicde
	if parent.repositioningTimer < 0:
		parent.repositioningTimer = parent.maxRepositioningTimer
		return decide_state

	return null


func reposition() -> void:
	if parent.target == null:
		return
	var random_offset := Vector2(
		randf_range(-positioning_radius, positioning_radius),
		randf_range(-positioning_radius, positioning_radius)
	)
	parent.navAgent.target_position = parent.target.global_position + random_offset


func exit() -> void:
	pass
