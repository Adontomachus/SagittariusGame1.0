extends Sprite2D

signal glow_on_beat()

@onready var glow_effect: PointLight2D = $GlowEffect
var energyIntensity: float

func _ready() -> void:
	energyIntensity = 4
	return

func _process(delta):
	energyIntensity -= 0.5 * delta
	glow_on_beat.emit(self.name)
	pass

func _on_glow_on_beat() -> void:
	glow_effect.energy = energyIntensity
	self_modulate = Color(1.0, 1.0, 0.0, 2.0)
	pass # Replace with function body.
