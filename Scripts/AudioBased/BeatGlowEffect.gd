class_name SpriteBeatGlow
extends Sprite2D



@export var glow_effect: PointLight2D

var energyIntensity: float

func _ready() -> void:
	_glow_on_beat()
	return



# Temporary Function
func _glow_on_beat() -> void:
	var tween = get_tree().create_tween()
	tween.tween_property(glow_effect, "energy", 4, 0.02)
	tween.tween_property(glow_effect, "energy", 0, 0.3)
	tween.play()
	await tween.finished
	tween.kill()
	return # Replace with function body.
