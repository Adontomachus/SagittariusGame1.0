class_name HitFlash
extends ColorRect

@export var flash_color: Color = Color(1.0, 0.0, 0.0, 0.4)
@export var flash_duration: float = 0.3

var tween: Tween

func _ready() -> void:
	color = Color(flash_color.r, flash_color.g, flash_color.b, 0.0)


func flash() -> void:
	if tween:
		tween.kill()
	color = flash_color
	modulate = flash_color
	tween = create_tween()
	tween.tween_property(self, "modulate", Color(flash_color.r, flash_color.g, flash_color.b, 0.0), flash_duration)\
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	print("isFlashing")

func nova_flash() -> void:
	if tween:
		tween.kill()
	tween = create_tween()
	color = Color(1.0, 1.0, 1.0, 1.0)
	visible = true
	## Hold briefly at full white
	tween.tween_interval(0.08)
	tween.tween_property(self, "color",
		Color(0.1, 0.8, 1.0, 0.6), 0.1)\
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	## Fully fade out
	tween.tween_property(self, "color",
		Color(0.1, 0.8, 1.0, 0.0), 0.4)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
