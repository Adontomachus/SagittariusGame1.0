extends CPUParticles2D


	
func _ready():
	print("Effect Instantiated!")

func _on_shot_effect_finished() -> void:
	queue_free()
	pass # Replace with function body.
