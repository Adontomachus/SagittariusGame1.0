class_name BeatSync_Script
extends Panel

## Signals section
signal player_shoot_projectile(damage_modifier: float, projectile_modulation: Color)
signal increase_player_attack_charge
signal increment_combo_meter(strength_value: float)
signal border_pulse
signal beat_happened

@export_category("Beat Settings")
@export var level_song: AudioStreamPlayer # = $"../MetronomeTest"
##TEMPORARY
var can_play: bool = true
##TEMPORARY
@onready var indicator_sprite: Sprite2D = $"../IndicatorSprite"



#region Beat Variables
@export var tempo: float = 107
var pulsePerBeat = 60.0 / tempo
var halfPulsePerBeat = 60.0 / (tempo * 2)
var halfLastBeat = 0
var lastBeat = 0

## Flag that forces only one type of fire to be used per beat
var beat_consumed: bool = false

## Secondary ammo counter, along with the player interface from it
@export var secondary_ammo_container: Node
var secondary_ammo: int = 0

## Variables for the full note
var time: float
var beat: float
var beat_precise: float
## Variables for half note
var half_time: float
var half_beat: float
var half_beat_precise: float
## Variables for half note
var audio_latency: float = 0.0
#endregion

#region UI Combo Counter along with the actual combo counter
@export var comboCounter = 0
var combo_audio_pitch: float = 1
@onready var p_combo_sound: AudioStreamPlayer2D = $PerfectShotComboSound
#endregion

#region other UI elements to beat sync for diegetic effectss
@onready var p_feedback: AnimationPlayer = $"../../Border Pulse/PerfectPulseFeedback"
#region Region for beat indicator animations for players to follow through
@onready var beat_indicator_animation: AnimationPlayer = $"../BeatIndicatorAnimation"

## TEST / TEMPORARY
@onready var glow_effect: AnimationPlayer = $"../../../GlowAnimationPlayer"

#endregion
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
@export var perfect_hit: float = 0.03
@export var good_hit: float = 0.07
@export var ok_hit: float = 0.14
#endregion




func _ready() -> void:
	# Connect the shooting response to the player shoot function
	var player = get_tree().get_first_node_in_group("PlayerObject")
	player_shoot_projectile.connect(player._shoot_projectile)
	increase_player_attack_charge.connect(player.increment_player_charge_attack)
	# Get the latency
	audio_latency = AudioServer.get_output_latency()
	
	beat_happened.connect(player.q_moves.on_beat)

	scale = Vector2(starting_scale, starting_scale)
	
func _process(_delta) -> void:
	secondary_ammo_container.shots_available = secondary_ammo
	p_combo_sound.pitch_scale = combo_audio_pitch
	combo_audio_pitch = 1 + (comboCounter * 0.06)
	# For combo text
	if level_song.playing == false:
		return

	# Time
	time = level_song.get_playback_position() + AudioServer.get_time_since_last_mix()
	time -= audio_latency
	time = max(0, time)

	if time < 0.1:
		lastBeat = 0
		GlobalBeatSync.lastBeat = lastBeat

	## Full note precision
	beat_precise = time / pulsePerBeat
	beat = floorf(beat_precise)
	## Half note precision
	half_beat_precise = time / halfPulsePerBeat
	half_beat = floorf(half_beat_precise)
	
	GlobalBeatSync.beat = beat
	# GlobalBeatSync.half_beat = beat
	## Take actions when a note has passed
	if lastBeat < beat:
		GlobalBeatSync.notesPassed += 1
		GlobalBeatSync.executeAction = true
		indicator_pulse()
		lastBeat = beat
		halfLastBeat = half_beat  # keep them in sync on full beats
		beat_consumed = false
		beat_happened.emit() # caller for q moves 
	if halfLastBeat < half_beat:
		indicator_pulse()
		halfLastBeat = half_beat
		beat_consumed = false  
		beat_happened.emit()

func _input(event: InputEvent) -> void:
	if beat_consumed:            # block if already fired this beat
		return
	var beat_fraction := fmod(beat_precise, 1.0)
	
	# Distance to full beat (0.0 or 1.0)
	var full_beat_timing: float = min(abs(beat_fraction),abs(1.0 - beat_fraction))
	
	# Distance to half beat (0.5)
	var half_beat_timing :float = abs(0.5 - beat_fraction)
	
	# Use whichever is closer
	var timing :float = min(full_beat_timing, half_beat_timing)
	if event.is_action_pressed("fire_weapon"):
		var result = evaluate_shot(timing)
		player_shoot_projectile.emit(result.damage, result.color)

func evaluate_shot(timing: float) -> Dictionary:
	if timing < perfect_hit:
		comboCounter += 1
		combo_audio_pitch = 1 + (comboCounter * 0.06)
		PointSystemScript.playerScore += 1
		p_feedback.play("PerfectPulse")
		border_pulse.emit()
		p_combo_sound.play()
		increase_player_attack_charge.emit()
		if secondary_ammo < 6:
			secondary_ammo += 1
		increment_combo_meter.emit(40)
		return { "damage": 1.45, "color": Color.html("#1ce1ebff") }
	if timing < good_hit:
		comboCounter += 1
		increment_combo_meter.emit(15)
		return { "damage": 1.0, "color": Color.html("#53bc07ff") }
	if timing < ok_hit:
		comboCounter += 1
		return { "damage": 0.8, "color": Color.html("#f0f816ff") }
	comboCounter = 0
	return { "damage": 0.1, "color": Color.html("#ff3b2dff") }





func indicator_pulse() -> void:
	print("Total Accuracy: ", PointSystemScript.accuracy , "%")
	if tween:
		tween.kill()
	tween = create_tween()

	scale = Vector2(starting_scale, starting_scale)
	tween.tween_property(self, "scale", Vector2(1.0, 1.0), pulsePerBeat / 1.0).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN_OUT)
	## For debug purposes



func perfect_pulse_feedback() -> void:
	return
	
func _combo_pulse() -> void:
	## Sets the animation speed to match with the tempo, then plays it
	combo_animation_pulse.speed_scale = tempo / 235
	combo_animation_pulse.play("UIBeatPulse")
	beat_indicator_animation.speed_scale = tempo / 32
	beat_indicator_animation.play("RhythmIndicator")
	glow_effect.play("GlowPulse")
