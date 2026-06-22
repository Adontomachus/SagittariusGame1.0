extends Node

enum DamageSide {
	Player,
	Enemy
}

@export var indicator_side = DamageSide.Player
@onready var damage_text: Label = $"."
var starting_font_size = 1

@export_category("Damage Number Properties")
@export var damage_value: int = 46
@export var is_critical_hit: bool
@export var fade_duration: float = 0.8
@export var damage_num_size: float = 25
@export var maximum_velocity: float = 100

@export var hold_duration: float = 0.2

var move_direction: Vector2
var move_speed: float


func _ready() -> void:
	starting_font_size += damage_value / 2
	fade_duration += damage_value / 1000
	if is_critical_hit:
		damage_num_size = 75
		damage_text.text = str(round(damage_value)) + "!"
	else:
		damage_text.text = str(round(damage_value))

	## Start small before the pop animation begins
	damage_text.set("theme_override_font_sizes/font_size", 12)

	_fade_out(fade_duration)
	var random_angle = randf_range(0, TAU)
	move_speed = randf_range(0, 100)
	move_direction = Vector2.from_angle(random_angle)


func _fade_out(fadeDuration) -> void:
	var tween = get_tree().create_tween()

	tween.tween_property(
		damage_text,
		"theme_override_font_sizes/font_size",
		1,
		0.1
	).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(
		damage_text,
		"theme_override_font_sizes/font_size",
		damage_num_size + (damage_value * 0.25),
		0.05
	).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

	tween.tween_property(
		damage_text,
		"theme_override_font_sizes/font_size",
		damage_num_size + (damage_value * .1),
		0.10
	).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)

	## Hold
	tween.tween_interval(hold_duration)

	## Fade out
	tween.set_parallel(true)
	tween.tween_property(self, "modulate:a", 0, fadeDuration)
	tween.tween_property(self, "self_modulate:a", 0, fadeDuration)
	tween.set_parallel(false)

	await tween.finished
	queue_free()


func _process(_delta: float) -> void:
	self.position += move_direction * move_speed * _delta
