class_name BeatSync_Script
extends Panel

signal player_shoot_projectile(damage_modifier: float, projectile_modulation: Color)
@export_category("Beat Settings")
@export var metronome_test: AudioStreamPlayer# = $"../MetronomeTest"

#region Beat Variables
@export var tempo: float = 120.0
var pulsePerBeat = 60.0 / tempo
var lastBeat = 0

var time: float
var beat: float
var beat_precise: float

var audio_latency: float = 0.0
#endregion

#region Indicator Variables
@export var starting_scale: float = 1.35
var tween: Tween
#endregion

#region Damage Variables
@export_category("Damage Output")
## The window for a perfect shot. The closer the timing is to this number, the better the score.
@export var fire_window: float = 0.5

@export_category("Fire Timings")
@export var perfect_hit: float = 0.42
@export var good_hit: float = 0.34
@export var ok_hit: float = 0.28
#endregion

func _ready() -> void:
	# Connect the shooting response to the player shoot function
	var player = get_tree().get_first_node_in_group("PlayerObject")
	player_shoot_projectile.connect(player._shoot_projectile)

	# Get the latency
	audio_latency = AudioServer.get_output_latency()

	scale = Vector2(starting_scale, starting_scale)
	
func _process(_delta) -> void:
	if metronome_test.playing == false:
		return

	time = metronome_test.get_playback_position() + AudioServer.get_time_since_last_mix()
	time -= audio_latency
	time = max(0, time)

	if time < 0.1:
		lastBeat = 0

	beat_precise = time / pulsePerBeat
	beat = floorf(beat_precise)

	if lastBeat < beat:
		#print("Note passed!")
		indicator_pulse()
		lastBeat = beat

func _input(event: InputEvent) -> void:
	var timing: float = abs((beat_precise - beat) - fire_window)

	if event.is_action_pressed("fire_weapon"):
		player_shoot_projectile.emit(damage_modifier(timing), projectile_color(timing))

func damage_modifier(timing: float) -> float:
	# Perfect
	if timing > perfect_hit:
		return 1.2

	# Good
	if timing > good_hit:
		return 1.0
	
	# OK
	if timing > ok_hit:
		return 0.9
	
	# BAD
	return 0.3

func projectile_color(timing: float) -> Color:
	# Perfect
	if timing > perfect_hit:
		return Color.html("rgba(32, 255, 255, 1)")

	# Good
	if timing > good_hit:
		return Color.html("#53bc07ff")
	
	# OK
	if timing > ok_hit:
		return Color.html("#f0f816ff")

	# BAD
	return Color.html("#ff3b2dff")

func indicator_pulse() -> void:
	if tween:
		tween.kill()
	tween = create_tween()

	scale = Vector2(starting_scale, starting_scale)
	tween.tween_property(self, "scale", Vector2(1.0, 1.0), pulsePerBeat / 1.0).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN_OUT)
