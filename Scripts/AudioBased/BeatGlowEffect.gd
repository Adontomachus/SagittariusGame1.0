extends Sprite2D

signal glow_on_beat()

@onready var glow_effect: PointLight2D = $GlowEffect
var energyIntensity: float

func _ready() -> void:
	energyIntensity = 4
	return

func _process(delta):
	energyIntensity -= 0.5 * delta

	pass

func _on_glow_on_beat() -> void:
	glow_effect.energy = energyIntensity

	pass # Replace with function body.
