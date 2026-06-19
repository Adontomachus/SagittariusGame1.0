
extends StaticBody2D



var energyIntensity: float
@onready var glow_effect: PointLight2D = $GlowEffect

func _ready() -> void:
	call_deferred("_connect_to_beat_pulse")

func _connect_to_beat_pulse() -> void:
	var manager := get_tree().get_first_node_in_group("GManager")
	if manager == null:
		push_error("GlowObject: GManager not found in group 'GManager'")
		return
	if not manager.pulse_on_beat.is_connected(_glow_on_beat):
		manager.pulse_on_beat.connect(_glow_on_beat)

# Temporary Function
func _glow_on_beat() -> void:
	var tween = get_tree().create_tween()
	tween.tween_property(glow_effect, "energy", 3, 0.01)
	tween.tween_property(glow_effect, "energy", 0, 0.3)
	tween.play()
	await tween.finished
	tween.kill()
	print("this shit was called")
