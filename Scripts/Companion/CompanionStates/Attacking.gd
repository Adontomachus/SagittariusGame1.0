class_name CompanionStateAttacking
extends CompanionState
@export var base_duration: float = 3.0
var duration: float = 0.0

@export var after_attacking_state: CompanionState
# Called when the node enters the scene tree for the first time.
func enter() -> void:
	super()
	duration = base_duration * parent.aggressiveness
	pass # Replace with function body.
	
func process_physics(delta: float) -> CompanionState:
	if parent.nearest_enemy == null:
		return after_attacking_state  ## no enemy — stop attacking

	parent._rush_towards_target(delta)
	target_chase()
	duration -= 1 * delta

	if duration < 0:
		return after_attacking_state  ## duration expired — stop attacking

	return null  ## stay in attack state







func target_chase() -> void:
	if parent.enemy_target_marker:
		parent.pathfinding.target_position = parent.enemy_target_marker.global_position
	return

func exit() -> void:
	pass
