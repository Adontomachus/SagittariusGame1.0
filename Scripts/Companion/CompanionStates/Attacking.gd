class_name CompanionStateAttacking
extends CompanionState

@export var base_duration: float = 3.0
var duration: float = 0.0
@export var after_attacking_state: CompanionState

## Ranged support keeps this distance from the enemy
@export var preferred_range: float = 300.0


func enter() -> void:
	super()
	duration = base_duration * parent.aggressiveness


func process_physics(delta: float) -> CompanionState:
	if parent.nearest_enemy == null:
		return after_attacking_state

	match parent.role:
		CompanionGroup.CompanionRole.MELEE_STRIKER:
			## Striker rushes directly at the enemy
			parent._rush_towards_target(delta)
			target_chase()

		CompanionGroup.CompanionRole.RANGED_SUPPORT:
			## Support maintains distance — moves toward enemy until in range
			## then holds position and lets _support_on_beat() handle shooting
			var dist := parent.global_position.distance_to(parent.nearest_enemy.global_position)
			if dist > preferred_range:
				## Move closer until in preferred range
				target_chase()
				parent.move_companion(delta)
			else:
				## Hold position — shooting is handled by beat signal in CompanionGroup
				parent.velocity = Vector2.ZERO
				parent.move_and_slide()

	duration -= delta
	if duration < 0:
		return after_attacking_state

	return null


func target_chase() -> void:
	if parent.enemy_target_marker:
		parent.pathfinding.target_position = parent.enemy_target_marker.global_position


func exit() -> void:
	pass
