extends StaticBody2D

@onready var glow_effect: PointLight2D = $GlowEffect

## Base flicker settings
@export var flicker_min: float = 0.4
@export var flicker_max: float = 0.9
@export var flicker_speed: float = 3.5   

## Beat pulse settings
@export var beat_peak_energy: float = 2.5
@export var beat_decay_speed: float = 0.8  

var flicker_time: float = 0.0
var beat_boost: float = 0.0 
var tween: Tween


func _ready() -> void:
	## Randomize flicker phase so multiple torches don't pulse in unison
	flicker_time = randf() * TAU
	call_deferred("_connect_to_beat_pulse")


func _process(delta: float) -> void:
	## Advance flicker at slightly random speed for organic feel
	flicker_time += delta * flicker_speed * randf_range(0.85, 1.15)

	## Layered sine waves for more natural flame movement
	var flicker := (
		sin(flicker_time) * 0.4 +
		sin(flicker_time * 2.3) * 0.2 +
		sin(flicker_time * 5.7) * 0.08
	)
	var base_energy := lerpf(flicker_min, flicker_max, (flicker + 1.0) * 0.5)

	## Beat boost decays back to zero naturally
	beat_boost = lerpf(beat_boost, 0.0, delta * (1.0 / beat_decay_speed))

	glow_effect.energy = base_energy + beat_boost


func _connect_to_beat_pulse() -> void:
	var manager := get_tree().get_first_node_in_group("GManager")
	if manager == null:
		push_error("GlowObject: GManager not found in group 'GManager'")
		return
	if not manager.pulse_on_beat.is_connected(_glow_on_beat):
		manager.pulse_on_beat.connect(_glow_on_beat)


func _glow_on_beat() -> void:
	## Snap the beat boost to peak — it then naturally decays in _process
	beat_boost = beat_peak_energy - glow_effect.energy
