extends GPUParticles2D

@export var orbit_color: Color = Color.WHITE
#@export var orbit_glow : PointLight2D


func _ready() -> void:
	if process_material:
		process_material = process_material.duplicate()
	set_effect_color(orbit_color)
#	orbit_glow.color = orbit_color


func set_effect_color(color: Color) -> void:
	if process_material is ParticleProcessMaterial:
		var mat := process_material as ParticleProcessMaterial
		var gradient := Gradient.new()
		gradient.add_point(0.0, Color(color.r, color.g, color.b, 1.0))
		gradient.add_point(1.0, Color(color.r, color.g, color.b, 0.0))
		var gradient_texture := GradientTexture1D.new()
		gradient_texture.gradient = gradient
		mat.color_ramp = gradient_texture
