class_name ComboUIFeedback
extends Node

@export var combo_label: Label
@export var combo_system: ComboSystems

@export_category("Punch Settings")
@export var punch_scale: Vector2 = Vector2(1.3, 1.3)
@export var punch_duration: float = 0.12
@export var base_scale: Vector2 = Vector2(1.0, 1.0)

@export_category("Shake Settings")
@export var shake_strength: float = 8.0
@export var shake_duration: float = 0.15
@export var shake_steps: int = 6

var tween: Tween
var shake_tween: Tween
var original_position: Vector2


func _ready() -> void:
	original_position = combo_label.position
	add_to_group("ComboUIFeedback")


func on_particle_arrived(value: float) -> void:
	if combo_system:
		combo_system._add_combo_level(value)
	_punch()
	_shake()


func _punch() -> void:
	if tween:
		tween.kill()
	tween = create_tween()
	combo_label.scale = punch_scale
	tween.tween_property(combo_label, "scale", base_scale, punch_duration)\
		.set_trans(Tween.TRANS_BACK)\
		.set_ease(Tween.EASE_OUT)


func _shake() -> void:
	if shake_tween:
		shake_tween.kill()
	shake_tween = create_tween()
	for i in range(shake_steps):
		var offset := Vector2(
			randf_range(-shake_strength, shake_strength),
			randf_range(-shake_strength, shake_strength)
		)
		shake_tween.tween_property(combo_label, "position",
			original_position + offset,
			shake_duration / shake_steps
		)
	shake_tween.tween_property(combo_label, "position",
		original_position,
		shake_duration / shake_steps
	)
