class_name HitFlashEnemy
extends Node

@export var target: CanvasItem  ## accepts Sprite2D, AnimatedSprite2D, or any drawable node
@export var flash_duration: float = 1
@export var shake_strength: float = 6.0
@export var shake_duration: float = 0.2

var flash_tween: Tween
var shake_tween: Tween
var original_position: Vector2
var mat: ShaderMaterial


func _ready() -> void:
	if target == null:
		push_error("HitFlashEnemy: target not assigned")
		return
	## Store original position for shake reset
	if target is Node2D:
		original_position = (target as Node2D).position
	## Setup shader
	if target.material:
		target.material = target.material.duplicate()
		mat = target.material as ShaderMaterial
	else:
		mat = ShaderMaterial.new()
		mat.shader = _create_flash_shader()
		target.material = mat
	mat.set_shader_parameter("flash_amount", 0.0)


func flash() -> void:
	if mat == null:
		return
	if flash_tween:
		flash_tween.kill()
	flash_tween = create_tween()
	mat.set_shader_parameter("flash_amount", 1.0)
	flash_tween.tween_method(
		func(v: float): mat.set_shader_parameter("flash_amount", v),
		1.0, 0.0, flash_duration
	).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	_shake()


func _shake() -> void:
	if target == null or not target is Node2D:
		return
	var node := target as Node2D
	if shake_tween:
		shake_tween.kill()
	shake_tween = create_tween()
	var steps := 6
	for i in range(steps):
		var offset := Vector2(
			randf_range(-shake_strength, shake_strength),
			randf_range(-shake_strength, shake_strength)
		)
		shake_tween.tween_property(node, "position",
			original_position + offset,
			shake_duration / steps
		)
	shake_tween.tween_property(node, "position", original_position, shake_duration / steps)


func _create_flash_shader() -> Shader:
	var shader := Shader.new()
	shader.code = """
shader_type canvas_item;
uniform float flash_amount : hint_range(0.0, 1.0) = 0.0;
void fragment() {
	vec4 tex = texture(TEXTURE, UV);
	if (tex.a < 0.01) discard;
	COLOR = mix(tex, vec4(1.0, 1.0, 1.0, tex.a), flash_amount);
}
"""
	return shader
