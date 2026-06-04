class_name ComboParticle
extends Node2D

@export var move_speed: float = 400.0
@export var acceleration: float = 600.0
@export var combo_value: float = 0.0

var target_pos: Vector2
var current_speed: float = 100.0
var is_homing: bool = false
var reached_target: bool = false

signal reached_combo_ui(value: float)


func _ready() -> void:
	## Find the combo UI position
	var combo_ui := get_tree().get_first_node_in_group("ComboUIFeedback")
	if combo_ui:
		target_pos = combo_ui.get_global_position()
		is_homing = true
	else:
		push_error("ComboParticle: ComboUI not found — add ComboSystem to ComboUI group")
		queue_free()

	## Small random offset on spawn for visual variety
	position += Vector2(randf_range(-20, 20), randf_range(-20, 20))


func _process(delta: float) -> void:
	if not is_homing or reached_target:
		return

	## Accelerate toward target
	current_speed = minf(current_speed + acceleration * delta, move_speed)

	var direction := (target_pos - global_position).normalized()
	global_position += direction * current_speed * delta

	## Spin for visual flair
	rotation += delta * 5.0

	## Check arrival
	if global_position.distance_to(target_pos) < 15.0:
		reached_target = true
		reached_combo_ui.emit(combo_value)
		queue_free()
