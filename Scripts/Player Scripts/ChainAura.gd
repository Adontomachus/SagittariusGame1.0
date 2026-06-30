class_name ChainAura
extends GPUParticles2D


func set_tier(tier: int, color: Color) -> void:
	if tier <= 0:
		emitting = false
		return

	emitting = true
	if process_material is ParticleProcessMaterial:
		var mat := process_material as ParticleProcessMaterial
		var gradient := Gradient.new()
		gradient.add_point(0.0, Color(color.r, color.g, color.b, 0.8))
		gradient.add_point(1.0, Color(color.r, color.g, color.b, 0.0))
		var gradient_texture := GradientTexture1D.new()
		gradient_texture.gradient = gradient
		mat.color_ramp = gradient_texture

	## Scale particle amount/speed with tier intensity
	amount = 8 + tier * 2
