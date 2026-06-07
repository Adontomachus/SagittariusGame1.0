class_name BeatSquashStretch
extends Node

## The node whose scale will be animated
@export var target: Node2D

@export_category("Squash and Stretch Settings")
## How much to squash/stretch on a full beat
@export var full_beat_intensity: float = .5
## How much to squash/stretch on a half beat
@export var half_beat_intensity: float = .25
## How quickly it returns to normal scale
@export var recovery_speed: float = 0.6
## The base scale to return to
@export var base_scale: Vector2 = Vector2(1.0, 1.0)
## If true, squashes on beat. If false, stretches on beat
@export var squash_on_beat: bool = true

var tween: Tween
var beat_sync: BeatSync_Script


func _ready() -> void:
	if beat_sync == null:
		beat_sync = get_tree().get_first_node_in_group("BeatSync")

	print("Target:", target)
	print("Target scale:", target.scale if target else "NULL")
	if target == null:
		push_error("BeatSquashStretch: target is null on ", name)
	
	_connect_to_beat_sync.call_deferred()
	

func _connect_to_beat_sync() -> void:
	var sync := get_tree().get_first_node_in_group("BeatSync")
	if sync == null:
		## Try again next frame — may still be loading
		await get_tree().process_frame
		sync = get_tree().get_first_node_in_group("BeatSync")
	if sync == null:
		push_error("BeatSquashStretch: BeatSync not found on ", name)
		return

	## Avoid double connecting
	if not sync.beat_happened.is_connected(_on_beat):
		sync.beat_happened.connect(_on_beat)
	if not sync.full_beat_happened.is_connected(_on_full_beat):
		sync.full_beat_happened.connect(_on_full_beat)
	print("BeatSquashStretch connected on: ", name)

func _exit_tree() -> void:
	var sync := get_tree().get_first_node_in_group("BeatSync")
	if sync == null:
		return
	if sync.beat_happened.is_connected(_on_beat):
		sync.beat_happened.disconnect(_on_beat)
	if sync.full_beat_happened.is_connected(_on_full_beat):
		sync.full_beat_happened.disconnect(_on_full_beat)


func _on_full_beat() -> void:
	print("_on_full_beat received")
	_apply_squash(full_beat_intensity)


func _on_beat() -> void:
	print("_on_beat received")
	_apply_squash(half_beat_intensity)


func _apply_squash(intensity: float) -> void:
	if target == null:
		print("target is null")
		return
	if tween:
		tween.kill()

	var squash_scale: Vector2
	if squash_on_beat:
		## Squash — wide and short
		squash_scale = Vector2(base_scale.x + intensity, base_scale.y - intensity)
		print("Trying to stretch")
	else:
		## Stretch — tall and narrow
		squash_scale = Vector2(base_scale.x - intensity, base_scale.y + intensity)
		print("Trying to stretch")

	tween = create_tween()
	## Snap to squash instantly
	tween.tween_property(target, "scale", squash_scale, 0.0)
	## Bounce back with overshoot
	tween.tween_property(target, "scale", base_scale, 1.0 / recovery_speed)\
		.set_trans(Tween.TRANS_ELASTIC)\
		.set_ease(Tween.EASE_OUT)


## Call this externally for own pulse
func pop(intensity: float = 0.3) -> void:
	_apply_squash(intensity)


## Call to temporarily disable squash 
func set_enabled(enabled: bool) -> void:
	if enabled:
		if not beat_sync.beat_happened.is_connected(_on_beat):
			beat_sync.beat_happened.connect(_on_beat)
		if not beat_sync.full_beat_happened.is_connected(_on_full_beat):
			beat_sync.full_beat_happened.connect(_on_full_beat)
	else:
		if beat_sync.beat_happened.is_connected(_on_beat):
			beat_sync.beat_happened.disconnect(_on_beat)
		if beat_sync.full_beat_happened.is_connected(_on_full_beat):
			beat_sync.full_beat_happened.disconnect(_on_full_beat)
