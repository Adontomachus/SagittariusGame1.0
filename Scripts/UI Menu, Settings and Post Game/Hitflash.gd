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

	## Instantly set to flash color then fade out
	color = flash_color
	modulate = flash_color
	tween = create_tween()
	tween.tween_property(self, "modulate", Color(flash_color.r, flash_color.g, flash_color.b, 0.0), flash_duration)\
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	print("isFlashing")
