class_name ChainTierUI
extends Control

@export var tier_label: Label
@export var banner_label: Label
@export var banner_container: Control

var current_tier: int = 0
var last_chain_count: int = 0

var tier_names := {
	0: "",
	4: "COMET FORM",
	8: "CADENCE MODE",
	16: "ECHO NOVA"
}
var tier_colors := {
	4: Color(1.0, 0.8, 0.4),
	8: Color(0.5, 0.9, 1.0),
	16: Color(1.0, 0.3, 0.9)
}

var tween: Tween
var label_tween: Tween
var label_base_position: Vector2


func _ready() -> void:
	tier_label.text = ""
	banner_container.modulate.a = 0.0
	label_base_position = tier_label.position


func update_tier(perfect_chain: int) -> void:
	var new_tier := 0
	if perfect_chain >= 16:
		new_tier = 16
	elif perfect_chain >= 8:
		new_tier = 8
	elif perfect_chain >= 4:
		new_tier = 4

	if new_tier > 0:
		tier_label.text = "%s  x%d" % [tier_names[new_tier], perfect_chain]
		tier_label.modulate = tier_colors[new_tier]
	else:
		tier_label.text = "Chain x%d" % perfect_chain if perfect_chain > 0 else ""

	## Punch + shake the label whenever the chain count goes up
	if perfect_chain > last_chain_count:
		_punch_label()
	last_chain_count = perfect_chain

	if new_tier != current_tier and new_tier > current_tier:
		_show_banner(tier_names[new_tier], tier_colors[new_tier])

	current_tier = new_tier


func _punch_label() -> void:
	if label_tween:
		label_tween.kill()
	label_tween = create_tween()

	## Set pivot to center so scale punch looks correct
	tier_label.pivot_offset = tier_label.size / 2.0

	## Punch scale
	tier_label.scale = Vector2(1.4, 1.4)
	label_tween.tween_property(tier_label, "scale", Vector2(1.0, 1.0), 0.2)\
		.set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)

	## Shake — small random offsets in parallel
	label_tween.parallel().tween_callback(_shake_label)


func _shake_label() -> void:
	var shake_tween := create_tween()
	var steps := 5
	var shake_strength := 4.0
	for i in range(steps):
		var offset := Vector2(
			randf_range(-shake_strength, shake_strength),
			randf_range(-shake_strength, shake_strength)
		)
		shake_tween.tween_property(tier_label, "position",
			label_base_position + offset, 0.03)
	shake_tween.tween_property(tier_label, "position", label_base_position, 0.03)


func reset_tier() -> void:
	current_tier = 0
	last_chain_count = 0
	tier_label.text = ""


func _show_banner(text: String, color: Color) -> void:
	banner_label.text = text
	banner_label.modulate = color
	if tween:
		tween.kill()
	tween = create_tween()
	banner_container.scale = Vector2(0.5, 0.5)
	banner_container.modulate.a = 1.0
	tween.tween_property(banner_container, "scale", Vector2(1.2, 1.2), 0.15)\
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(banner_container, "scale", Vector2(1.0, 1.0), 0.1)\
		.set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	tween.tween_interval(0.8)
	tween.tween_property(banner_container, "modulate:a", 0.0, 0.4)\
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
