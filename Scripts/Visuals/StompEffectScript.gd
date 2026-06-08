extends Node2D
@export var shot_effect: CPUParticles2D

@export var shakes_camera: bool = false
@export var stomp_animation: AnimationPlayer

@export var camera: CameraControl
@export var timedShot: float = 1

func _process(delta):
	timedShot -= delta
	if (timedShot < 0):
		queue_free()

func _ready():
	
	stomp_animation.play("Shockwave")
	
	var camera = get_tree().get_first_node_in_group("CameraControl")
	if camera: 
		camera.add_trauma(0.6) 
	
	print("Particles emitted!")

func _on_finished() -> void:
	queue_free()
	pass # Replace with function body.
