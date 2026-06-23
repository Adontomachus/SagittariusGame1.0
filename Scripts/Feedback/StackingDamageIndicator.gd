extends Node

enum DamageSide {
	Player,
	Enemy
}

@export var indicator_side = DamageSide.Player

# @onready var damage_text: Label = $"."
var starting_font_size = 45

@export_category("Damage Number Properties")
@export var damage_value: int = 46
@export var fade_duration: float = 0.8
@export var damage_num_size: float = 80
@export var maximum_velocity: float = 100
@export var is_fading: bool = false
var before_fade_duration: float
var max_before_fade_duration: float = 1
var can_fade: bool = true

var move_direction: Vector2
var move_speed: float
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.modulate.a = 0
	before_fade_duration = max_before_fade_duration
	starting_font_size += damage_value / 5
	fade_duration += damage_value / 1000
	# damage_text.text = str(round(damage_value))
	var random_angle = randf_range(0, TAU)
	# move_speed = randf_range(0,100)
	move_direction = Vector2.from_angle(random_angle)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if can_fade and is_fading:
		can_fade = false
		_fade_out(fade_duration)
	self.position += move_direction * move_speed * _delta
	#await get_tree().create_timer(1).timeout # wait 1 second
	#queue_free()
	before_fade_duration -= 1 * _delta
	if before_fade_duration <= 0:
		is_fading = true
	pass

func _flash_number():
	var tween = get_tree().create_tween()
	self.modulate.a = 1
	tween.tween_property(self, "theme_override_font_sizes/font_size", damage_num_size + damage_value / 15, 0.001)
	tween.tween_property(self, "theme_override_font_sizes/font_size", (damage_num_size - 55) + damage_value / 15, 0.11)
	tween.play()

func _fade_out(fadeDuration):
	var tween = get_tree().create_tween()
	tween.tween_property(self, "modulate:a", 0, fadeDuration)
	tween.tween_property(self, "self_modulate:a", 0, fadeDuration)
	tween.play()
	await tween.finished
	tween.kill()
	queue_free()
