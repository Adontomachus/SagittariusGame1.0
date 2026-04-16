class_name CompanionStateAttacking
extends CompanionState

# Called when the node enters the scene tree for the first time.
func enter() -> void:
	super()
	# parent.pathfinding.enabled = false
			
		
	pass # Replace with function body.




func _dash_towards_target(dash_target) -> void:
	parent.is_dashing = true
	pass
