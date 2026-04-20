class_name CompanionStateAttacking
extends CompanionState

@export var duration: float = 1
@export var after_attacking_state: CompanionState
# Called when the node enters the scene tree for the first time.
func enter() -> void:
	super()

	# parent.pathfinding.enabled = false
			
	pass # Replace with function body.
	
func process_physics(delta: float) -> CompanionState:
	parent._rush_towards_target()
	duration -= 1 * delta
	if duration < 0:
		return after_attacking_state
	return
