
extends StaticBody2D



var energyIntensity: float
@onready var glow_effect: PointLight2D = $PointLight2D

func _ready() -> void:
	#_glow_on_beat()
	return



# Temporary Function
func _glow_on_beat() -> void:
	var tween = get_tree().create_tween()
	tween.tween_property(glow_effect, "energy", 3, 0.01)
	tween.tween_property(glow_effect, "energy", 0, 0.3)
	tween.play()
	await tween.finished
	tween.kill()
	pass # Replace with function body.
