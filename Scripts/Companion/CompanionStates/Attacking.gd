class_name CompanionStateAttacking
extends CompanionState

@export var duration: float = 3
@export var after_attacking_state: CompanionState
# Called when the node enters the scene tree for the first time.
func enter() -> void:
	super()
	pass # Replace with function body.
	
func process_physics(delta: float) -> CompanionState:
	parent._rush_towards_target(delta)
	target_chase()
	duration -= 1 * delta
	if duration < 0:
		return after_attacking_state
	return

func target_chase() -> void:
	if parent.enemy_target_marker:
		parent.pathfinding.target_position = parent.enemy_target_marker.global_position
	return
