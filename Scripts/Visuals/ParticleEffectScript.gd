extends Node2D
@export var shot_effect: CPUParticles2D

@export var shakes_camera: bool = false
@export var is_shockwave_effect: bool = false
@export var stomp_animation: AnimationPlayer
@export var has_ripple_effects: bool = false

@export var camera: CameraControl
@export var timedShot: float = 1
@export var ripple_fade: AnimationPlayer

func _process(delta):
	timedShot -= delta
	if (timedShot < 0):
		queue_free()

func _ready():
	if has_ripple_effects:
		ripple_fade.play("Fade")
	if is_shockwave_effect:
		stomp_animation.play("Shockwave")
		var camera = get_tree().get_first_node_in_group("CameraControl")
		if camera: camera.add_trauma(0.6) 
	
	print("Particles emitted!")

func _on_finished() -> void:
	queue_free()
	pass # Replace with function body.
