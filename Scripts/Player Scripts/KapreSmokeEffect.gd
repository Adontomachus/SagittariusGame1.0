class_name KapreSmokeEffect
extends Node2D

@export var smoke_particles: GPUParticles2D
@export var smoke_color: Color = Color(0.15, 0.12, 0.1, 0.85)
@export var linger_duration: float = 1


func _ready() -> void:
	if smoke_particles == null:
		push_error("KapreSmokeEffect: smoke_particles not assigned")
		return

	## Make material unique per instance
	if smoke_particles.process_material:
		smoke_particles.process_material = smoke_particles.process_material.duplicate()

	_apply_color()
	smoke_particles.emitting = true

	## Free this node once particles have fully finished (lifetime + linger)
	await get_tree().create_timer(linger_duration + smoke_particles.lifetime).timeout
	queue_free()


func _apply_color() -> void:
	var mat := smoke_particles.process_material as ParticleProcessMaterial
	if mat == null:
		return

	var gradient := Gradient.new()
	gradient.add_point(0.0, Color(smoke_color.r, smoke_color.g, smoke_color.b, 0.0))
	gradient.add_point(0.15, Color(smoke_color.r, smoke_color.g, smoke_color.b, smoke_color.a))
	gradient.add_point(0.7, Color(smoke_color.r * 0.8, smoke_color.g * 0.8, smoke_color.b * 0.8, smoke_color.a * 0.6))
	gradient.add_point(1.0, Color(smoke_color.r * 0.6, smoke_color.g * 0.6, smoke_color.b * 0.6, 0.0))

	var gradient_texture := GradientTexture1D.new()
	gradient_texture.gradient = gradient
	mat.color_ramp = gradient_texture
