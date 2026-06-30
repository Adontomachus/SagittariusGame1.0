class_name ChainBorderGlow
extends ColorRect

var mat: ShaderMaterial
var tween: Tween


func _ready() -> void:
	mat = material as ShaderMaterial
	if mat:
		mat.set_shader_parameter("intensity", 0.0)


func set_tier(tier: int, color: Color) -> void:
	if mat == null:
		return
	if tween:
		tween.kill()
	tween = create_tween()

	mat.set_shader_parameter("glow_color", color)

	var target_intensity := 0.0
	match tier:
		4: target_intensity = 0.3
		8: target_intensity = 0.5
		16: target_intensity = 0.8

	tween.tween_method(
		func(v): mat.set_shader_parameter("intensity", v),
		mat.get_shader_parameter("intensity"), target_intensity, 0.3
	)


func clear() -> void:
	if tween:
		tween.kill()
	tween = create_tween()
	tween.tween_method(
		func(v): mat.set_shader_parameter("intensity", v),
		mat.get_shader_parameter("intensity"), 0.0, 0.4
	)
