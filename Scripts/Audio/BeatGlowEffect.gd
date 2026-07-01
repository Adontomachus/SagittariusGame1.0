class_name SpriteBeatGlow
extends Node2D

@onready var glow_effect: PointLight2D = $GlowEffect

@export var base_energy: float = 0.8
@export var peak_energy: float = 3.2


func _ready() -> void:
	glow_effect.energy = base_energy
	_glow_on_beat()


# Flame-like glow pulse
func _glow_on_beat() -> void:
	var tween := create_tween()

	## Randomized peak for organic flame flicker
	var random_peak := randf_range(peak_energy * 0.85, peak_energy * 1.15)

	tween.tween_property(
		glow_effect,
		"energy",
		random_peak,
		0.12
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

	tween.tween_property(
		glow_effect,
		"energy",
		base_energy + randf_range(0.15, 0.4),
		0.18
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	tween.tween_property(
		glow_effect,
		"energy",
		base_energy,
		0.25
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
