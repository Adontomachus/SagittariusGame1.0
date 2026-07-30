class_name BeatSync_Script
extends Panel

## Signals section
signal player_shoot_projectile(damage_modifier: float, projectile_modulation: Color)
signal increase_player_attack_charge
signal border_pulse
signal beat_happened
signal full_beat_happened

@export_category("Beat Settings")
@export var level_song: AudioStreamPlayer

##TEMPORARY
var can_play: bool = true
##TEMPORARY
@onready var indicator_sprite: Sprite2D = $"../IndicatorSprite"

# Combo Systems
@export var combo_systems: ComboSystems

#region Beat Variables
@export var tempo: float = 107

## PUBLIC: other scripts read these (e.g., ShoutLob)
var pulsePerBeat: float
var halfPulsePerBeat: float

## PRIVATE: cached inverses for _process math optimization
var _inv_pulse: float
var _inv_half_pulse: float

func _update_tempo_cache() -> void:
	pulsePerBeat = 60.0 / tempo
	halfPulsePerBeat = pulsePerBeat * 0.5
	_inv_pulse = 1.0 / pulsePerBeat
	_inv_half_pulse = 1.0 / halfPulsePerBeat

var halfLastBeat := 0
var lastBeat := 0
var player

## Node export for a working secondary ammo counter
@export var secondary_ammo_counter: Node

## Flag that forces only one type of fire to be used per beat
var beat_consumed: bool = false
var secondary_ammo: int = 0

## Cached last ammo value to avoid redundant label updates
var _last_secondary_ammo: int = -1

## Variables for the full note
var time: float
var beat: int
var beat_precise: float
## Variables for half note
var half_beat: int
var half_beat_precise: float

var audio_latency: float = 0.0
#endregion

#region UI Combo Counter
@export var comboCounter := 0

## Cached last comboCounter to avoid redundant pitch recalculations
var _last_combo_counter: int = -1
var combo_audio_pitch: float = 1.0
@onready var p_combo_sound: AudioStreamPlayer2D = $PerfectShotComboSound
#endregion

#region other UI elements
@onready var p_feedback: AnimationPlayer = $"../../Border Pulse/PerfectPulseFeedback"
@onready var beat_indicator_animation: AnimationPlayer = $"../BeatIndicatorAnimation"

## TEST / TEMPORARY
@onready var glow_effect: AnimationPlayer = $"../../../GlowAnimationPlayer"

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
@export var fire_window: float = 0.5

@export_category("Fire Timings")
@export var perfect_hit: float = 0.03
@export var good_hit: float = 0.07
@export var ok_hit: float = 0.14
#endregion

var game_started := false

func start_game() -> void:
	level_song.stop()
	if game_started:
		return
	game_started = true
	if level_song and not level_song.playing:
		level_song.play()

func _ready() -> void:
	level_song.stop()
	_update_tempo_cache()

	player = get_tree().get_first_node_in_group("PlayerObject")
	player_shoot_projectile.connect(player._shoot_projectile)
	increase_player_attack_charge.connect(player.increment_player_charge_attack)

	## Cache audio latency once — it doesn't change during gameplay
	audio_latency = AudioServer.get_output_latency()

	beat_happened.connect(player.q_moves.on_beat)

	scale = Vector2(starting_scale, starting_scale)

	await get_tree().process_frame
	var squash_nodes := get_tree().get_nodes_in_group("BeatSquashStretch")
	print("Found squash nodes: ", squash_nodes.size())
	for node in squash_nodes:
		beat_happened.connect(node._on_beat)
		full_beat_happened.connect(node._on_full_beat)
		print("Connected: ", node.name)

func _process(_delta: float) -> void:
	if not game_started:
		return

	## Only update ammo label when value actually changes
	if secondary_ammo != _last_secondary_ammo:
		_last_secondary_ammo = secondary_ammo
		secondary_ammo_counter.shots_available = secondary_ammo

	## Only recalculate pitch when comboCounter changes
	if comboCounter != _last_combo_counter:
		_last_combo_counter = comboCounter
		combo_audio_pitch = 1.0 + (comboCounter * 0.06)
		p_combo_sound.pitch_scale = combo_audio_pitch

	if not level_song.playing:
		return

	# Single audio call path
	var playback: float = level_song.get_playback_position()
	var since_mix: float = AudioServer.get_time_since_last_mix()
	time = maxf(0.0, playback + since_mix - audio_latency)

	if time < 0.1:
		if lastBeat != 0:
			lastBeat = 0
			GlobalBeatSync.lastBeat = 0
		return

	# Use multiplication by cached inverses instead of division
	beat_precise = time * _inv_pulse
	beat = int(beat_precise)
	half_beat_precise = time * _inv_half_pulse
	half_beat = int(half_beat_precise)

	GlobalBeatSync.beat = beat

	if lastBeat < beat:
		GlobalBeatSync.notesPassed += 1
		GlobalBeatSync.executeAction = true
		indicator_pulse()
		lastBeat = beat
		halfLastBeat = half_beat
		beat_consumed = false
		beat_happened.emit()
		full_beat_happened.emit()

	if halfLastBeat < half_beat:
		indicator_pulse()
		halfLastBeat = half_beat
		beat_consumed = false
		beat_happened.emit()

func _input(event: InputEvent) -> void:
	if not game_started:
		return
	if beat_consumed:
		return

	var beat_fraction := fmod(beat_precise, 1.0)

	## Simplified timing math: distance to nearest beat (0.0 or 1.0) vs half beat (0.5)
	## Use raw subtraction instead of absf/minf chain where possible
	var dist_to_full: float = beat_fraction
	if dist_to_full > 0.5:
		dist_to_full = 1.0 - dist_to_full
	var dist_to_half: float = absf(0.5 - beat_fraction)
	var timing: float = dist_to_full if dist_to_full < dist_to_half else dist_to_half

	if event.is_action_pressed("fire_weapon"):
		var result := evaluate_shot(timing)
		player_shoot_projectile.emit(result.damage, result.color)

func evaluate_shot(timing: float) -> Dictionary:
	## PERFECT HIT
	if timing < perfect_hit:
		comboCounter += 1
		PointSystemScript.playerScore += 1
		p_feedback.play("PerfectPulse")
		border_pulse.emit()
		p_combo_sound.play()
		increase_player_attack_charge.emit()
		if player.cadence_mode:
			increase_player_attack_charge.emit()
		player.perfect_chain += 1
		player._update_chain_visuals()
		if player.tikbalang_step:
			player.tikbalang_speed_timer = 1.25
		if player.perfect_chain == 4:
			player._enable_comet_projectile()
		if player.perfect_chain == 8:
			player._enter_cadence_mode()
		if player.perfect_chain >= 16:
			player._trigger_echo_nova()
		return {"damage": 1.45, "color": Color.html("#1ce1ebff")}

	## GOOD HIT
	if timing < good_hit:
		comboCounter += 1
		player._on_missed_beat()
		if player.anito_blessing:
			if randf() <= 0.20:
				return evaluate_shot(perfect_hit * 0.5)
		return {"damage": 1.0, "color": Color.html("#53bc07ff")}

	## OK HIT
	if timing < ok_hit:
		comboCounter += 1
		player._on_missed_beat()
		return {"damage": 0.8, "color": Color.html("#f0f816ff")}

	## MISS — Kundiman Shield check
	if player.kundiman_shield and not player.kundiman_shield_used:
		print("Kundiman Shield saved the combo!")
		beat_consumed = true
		return {"damage": 0.5, "color": Color.html("#ffffff")}

	## Full miss — reset everything
	comboCounter = 0
	player._on_missed_beat()
	return {"damage": 0.1, "color": Color.html("#ff3b2dff")}

func indicator_pulse() -> void:
	## Reuse tween if still valid instead of kill/create every beat
	if tween and tween.is_valid():
		## Tween is still running from last beat, just restart scale
		scale = Vector2(starting_scale, starting_scale)
		return

	scale = Vector2(starting_scale, starting_scale)
	tween = create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(self, "scale", Vector2(1.0, 1.0), pulsePerBeat)

func perfect_pulse_feedback() -> void:
	pass

func _combo_pulse() -> void:
	combo_animation_pulse.speed_scale = tempo / 235.0
	combo_animation_pulse.play("UIBeatPulse")
	beat_indicator_animation.speed_scale = tempo / 32.0
	beat_indicator_animation.play("RhythmIndicator")
