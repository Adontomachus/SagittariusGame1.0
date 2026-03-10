extends Node

enum DamageSide {
	Player,
	Enemy
}

@export var indicator_side = DamageSide.Player

@onready var damage_text: Label = $"."

@export var damage_value: int = 46
@export var damage_crit: bool
@export var fade_duration: float = 1
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	damage_text.text = str(round(damage_value))
	_fade_out(fade_duration)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#await get_tree().create_timer(1).timeout # wait 1 second
	#queue_free()
	pass

func _fade_out(fadeDuration):
	var tween = get_tree().create_tween()
	tween.tween_property(self, "self_modulate:a", 1, fadeDuration)
	tween.play()
	await tween.finished
	tween.kill()
	queue_free()
