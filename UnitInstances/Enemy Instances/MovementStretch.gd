class_name MovementStretch
extends Node2D

@export var sprite_to_wrap: CanvasItem
@export var velocity_source: CharacterBody2D

@export_category("Bob Settings")
@export var bob_frequency: float = 1
@export var bob_intensity: float = .1
@export var max_speed_for_bob: float = 150.0
@export var smoothing: float = 6.0

@export var start_moving_threshold: float = 20.0
@export var stop_moving_threshold: float = 12.0

var current_intensity: float = 0.0
var bob_time: float = 0.0
var is_currently_moving: bool = false


func _process(delta: float) -> void:
	if sprite_to_wrap == null or velocity_source == null:
		return

	var speed := velocity_source.velocity.length()

	if not is_currently_moving and speed > start_moving_threshold:
		is_currently_moving = true
	elif is_currently_moving and speed < stop_moving_threshold:
		is_currently_moving = false

	if not is_currently_moving:
		current_intensity = 0.0
		bob_time = 0.0
		scale = Vector2.ONE
		position.y = 0.0
		return

	var target_intensity := clampf(speed / max_speed_for_bob, 0.0, 1.0)
	current_intensity = lerpf(current_intensity, target_intensity, smoothing * delta)

	bob_time += delta * bob_frequency * (0.5 + current_intensity)

	var bob_wave := sin(bob_time * TAU)
	var squash_factor: float = 1.0 - (bob_intensity * current_intensity * abs(bob_wave))
	var stretch_factor: float = 1.0 + (bob_intensity * current_intensity * abs(bob_wave) * 0.5)

	if bob_wave > 0:
		scale = Vector2(stretch_factor, squash_factor)
	else:
		scale = Vector2(squash_factor, stretch_factor)

	position.y = -abs(bob_wave) * 3.0 * current_intensity
