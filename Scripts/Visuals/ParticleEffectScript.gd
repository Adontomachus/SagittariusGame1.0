extends Node2D
@export var shot_effect: CPUParticles2D

var timedShot = 0.3

func _process(delta):
	timedShot -= delta
	if (timedShot < 0):
		queue_free()

func _ready():
	print("Particles emitted!")

func _on_finished() -> void:
	queue_free()
	pass # Replace with function body.
