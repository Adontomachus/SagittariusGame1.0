class_name NovaRing
extends Node2D

@export var expand_duration: float = 1
@export var max_radius: float = 1000.0
@export var ring_color: Color = Color(0.1, 0.9, 1.0, 0.8)
@export var ring_width: float = 6.0

var current_radius: float = 0.0
var current_alpha: float = 1.0
var tween: Tween


func _ready() -> void:
	_play_expand()


func _play_expand() -> void:
	tween = create_tween()
	tween.set_parallel(true)
	tween.tween_method(
		func(r: float): current_radius = r; queue_redraw(),
		0.0, max_radius, expand_duration
	).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_method(
		func(a: float): current_alpha = a; queue_redraw(),
		1.0, 0.0, expand_duration
	).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tween.chain().tween_callback(queue_free)


func _draw() -> void:
	if current_radius <= 0:
		return
	var color := Color(ring_color.r, ring_color.g, ring_color.b, ring_color.a * current_alpha)
	draw_arc(Vector2.ZERO, current_radius, 0, TAU, 64, color, ring_width, true)
	## Inner glow ring slightly smaller
	var inner_color := Color(1.0, 1.0, 1.0, current_alpha * 0.4)
	draw_arc(Vector2.ZERO, current_radius * 0.85, 0, TAU, 64, inner_color, ring_width * 0.5, true)
