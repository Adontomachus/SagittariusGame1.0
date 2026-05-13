class_name EnemyStateWindup
extends EnemyState

@export var telegraph_animation: AnimationPlayer
# Called when the node enters the scene tree for the first time.
func enter() -> void:
	telegraph_animation.play("Warning")
	super()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
