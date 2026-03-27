extends Node

enum DamageSide {
	Player,
	Enemy
}

@export var indicator_side = DamageSide.Player

@onready var damage_text: Label = $"."
var starting_font_size = 80

@export_category("Damage Number Properties")
@export var damage_value: int = 46
@export var is_critical_hit: bool
@export var fade_duration: float = 0.4
@export var damage_num_size: float = 80

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	starting_font_size += damage_value / 5
	fade_duration += damage_value / 1000
	if is_critical_hit:
		damage_num_size = 115
		damage_text.text = str(round(damage_value)) + "!"
	else:
		damage_text.text = str(round(damage_value))
	_fade_out(fade_duration)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	#await get_tree().create_timer(1).timeout # wait 1 second
	#queue_free()
	pass

func _fade_out(fadeDuration):
	var tween = get_tree().create_tween()
	tween.tween_property(self, "theme_override_font_sizes/font_size", damage_num_size + damage_value / 22, 0.001)
	tween.tween_property(self, "theme_override_font_sizes/font_size", (damage_num_size - 55) + damage_value / 22, 0.11)
	tween.tween_property(self, "modulate:a", 0, fadeDuration)
	tween.tween_property(self, "self_modulate:a", 0, fadeDuration)
	tween.play()
	await tween.finished
	tween.kill()
	queue_free()
