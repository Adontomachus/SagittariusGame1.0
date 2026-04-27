class_name BeatSync_Script
extends Panel

signal player_shoot_projectile(damage_modifier: float, projectile_modulation: Color)
signal increase_player_attack_charge
signal increment_combo_meter(strength_value: float)
signal border_pulse

@export_category("Beat Settings")
@export var level_song: AudioStreamPlayer # = $"../MetronomeTest"
##TEMPORARY
var can_play: bool = true
##TEMPORARY
@onready var indicator_sprite: Sprite2D = $"../IndicatorSprite"

#region Beat Variables
@export var tempo: float = 107
var pulsePerBeat = 60.0 / tempo
var lastBeat = 0

var time: float
var beat: float
var beat_precise: float
var audio_latency: float = 0.0
#endregion

#region UI Combo Counter along with the actual combo counter
@export var comboCounter = 0
var combo_audio_pitch: float = 1
@onready var p_combo_sound: AudioStreamPlayer2D = $PerfectShotComboSound
#endregion

#region other UI elements to beat sync for diegetic effects
@onready var score: Label = $"../PlayerInfo/Score"
@onready var wave_counter: Label = $"../PlayerInfo/WaveCounter"
@onready var p_feedback: AnimationPlayer = $"../Border Pulse/PerfectPulseFeedback"
## This variable is for the combo pulse effect where its speed dynamically
## aligns with the tempo
@export var combo_animation_pulse: AnimationPlayer
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


#region Global synchronization (TEMPORARY)
var delay: float = 0
#endregion

func _ready() -> void:
	# Connect the shooting response to the player shoot function
	var player = get_tree().get_first_node_in_group("PlayerObject")
	player_shoot_projectile.connect(player._shoot_projectile)

	# Get the latency
	audio_latency = AudioServer.get_output_latency()

	scale = Vector2(starting_scale, starting_scale)
	
func _process(_delta) -> void:
	## TEMPORARY
	#song_delay -= 1 * _delta
	#if song_delay < 0 and can_play:
	#	can_play = false
	#level_song.play()

	p_combo_sound.pitch_scale = combo_audio_pitch
	combo_audio_pitch = 1 + (comboCounter * 0.06)
	
	# For combo text
	if level_song.playing == false:
		return

	time = level_song.get_playback_position() + AudioServer.get_time_since_last_mix()
	time -= audio_latency
	time = max(0, time)

	if time < 0.1:
		lastBeat = 0
		GlobalBeatSync.lastBeat = lastBeat

	beat_precise = time / pulsePerBeat
	beat = floorf(beat_precise)
	GlobalBeatSync.beat = beat
	# Take actions when a note has passed
	if lastBeat < beat:
		print("Note passed!")
		GlobalBeatSync.notesPassed += 1
		GlobalBeatSync.executeAction = true
		print("Added Note!")
		indicator_pulse()
		#ui_pulse()
		lastBeat = beat

func _input(event: InputEvent) -> void:
	var timing: float = abs((beat_precise - beat) - fire_window)

	if event.is_action_pressed("fire_weapon"):
		player_shoot_projectile.emit(damage_modifier(timing), projectile_color(timing))

func damage_modifier(timing: float) -> float:
	# Perfect
	if timing > perfect_hit:
		p_feedback.play("PerfectPulse")
		border_pulse.emit()
		p_combo_sound.play()
		increase_player_attack_charge.emit()
		increment_combo_meter.emit(40)
		return 1.45

	# Good
	if timing > good_hit:
		comboCounter = 0
		increment_combo_meter.emit(15)
		return 1.0
	
	# OK
	if timing > ok_hit:
		comboCounter = 0
		return 0.8
	
	# BAD
	comboCounter = 0
	return 0.1

func projectile_color(timing: float) -> Color:
	# Perfect
	if timing > perfect_hit:
		comboCounter += 1
		return Color.html("#1ce1ebff")

	# Good
	if timing > good_hit:
		comboCounter += 1	
		return Color.html("#53bc07ff")

	# OK
	if timing > ok_hit:
		comboCounter += 1
		return Color.html("#f0f816ff")
		
	# BAD
	comboCounter = 0
	return Color.html("#ff3b2dff")




func indicator_pulse() -> void:
	if tween:
		tween.kill()
	tween = create_tween()

	scale = Vector2(starting_scale, starting_scale)
	tween.tween_property(self, "scale", Vector2(1.0, 1.0), pulsePerBeat / 1.0).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN_OUT)

func perfect_pulse_feedback() -> void:
	return
	
func _combo_pulse() -> void:
	combo_animation_pulse.speed_scale = tempo / 235
	combo_animation_pulse.play("UIBeatPulse")
#func ui_pulse() -> void:
#	if tween:
#		tween.kill()
#	tween = create_tween()
#	scale = Vector2(starting_scale, starting_scale)
#	
#	return
