class_name ChargeShotUI
extends Node2D

@export var sprite_empty: Sprite2D
@export var sprite_half: Sprite2D
@export var sprite_full: Sprite2D
@export var charge_shot: ChargeShot
@export var beat_sync: BeatSync_Script
@export var player: PlayerCharacter  ## reference to read perfect_chain

@export_category("Pulse Settings")
@export var pulse_scale: Vector2 = Vector2(1.35, 1.35)
@export var pulse_duration: float = 0.15
@export var base_scale: Vector2 = Vector2(1.0, 1.0)

@export_category("Light Settings")
@export var light: PointLight2D
@export var light_color_empty: Color = Color(0.5, 0.5, 1.0)
@export var light_color_half: Color = Color(0.8, 0.4, 1.0)
@export var light_color_full: Color = Color(1.0, 0.9, 0.0)
@export var light_energy_min: float = 0.4
@export var light_energy_max: float = 1.2
@export var light_energy_full: float = 2.0
@export var light_pulse_speed: float = 0.35

var tween: Tween
var light_tween: Tween
var current_sprite: Sprite2D
var last_state: int = -1


func _ready() -> void:
	if beat_sync == null:
		beat_sync = get_tree().get_first_node_in_group("BeatSync")
	if beat_sync:
		beat_sync.beat_happened.connect(_on_beat)
		beat_sync.full_beat_happened.connect(_on_full_beat)
	else:
		push_error("ChargeShotUI: BeatSync not found")

	if player == null:
		player = get_tree().get_first_node_in_group("PlayerObject")

	_set_state(0)


func _process(_delta: float) -> void:
	if player == null:
		return

	var chain := player.perfect_chain
	var new_state: int
	if chain >= 8:
		new_state = 2
	elif chain >= 4:
		new_state = 1
	else:
		new_state = 0

	if new_state != last_state:
		last_state = new_state
		_set_state(new_state)

func _set_state(state: int) -> void:
	if sprite_empty: sprite_empty.visible = false
	if sprite_half:  sprite_half.visible = false
	if sprite_full:  sprite_full.visible = false

	if light_tween:
		light_tween.kill()

	match state:
		0:
			current_sprite = sprite_empty
			if sprite_empty: sprite_empty.visible = true
			_set_light(light_color_empty, light_energy_min, light_energy_max)
		1:
			current_sprite = sprite_half
			if sprite_half: sprite_half.visible = true
			_set_light(light_color_half, light_energy_min, light_energy_max)
			_flash_transition(light_color_half)
		2:
			current_sprite = sprite_full
			if sprite_full: sprite_full.visible = true
			_set_light(light_color_full, light_energy_max, light_energy_full)
			_flash_transition(light_color_full)


func _on_beat() -> void:
	pass


func _on_full_beat() -> void:
	pass


func _pulse(scale_target: Vector2) -> void:
	if current_sprite == null:
		return
	if tween:
		tween.kill()
	tween = create_tween()
	current_sprite.scale = scale_target
	tween.tween_property(current_sprite, "scale", base_scale, pulse_duration)\
		.set_trans(Tween.TRANS_ELASTIC)\
		.set_ease(Tween.EASE_OUT)


func _pop(intensity: float) -> void:
	if current_sprite == null:
		return
	if tween:
		tween.kill()
	tween = create_tween()
	current_sprite.scale = Vector2(intensity, intensity)
	tween.tween_property(current_sprite, "scale", base_scale, 0.35)\
		.set_trans(Tween.TRANS_ELASTIC)\
		.set_ease(Tween.EASE_OUT)


func _flash_transition(color: Color) -> void:
	## Brief light flash when upgrading to a new tier
	if light == null:
		return
	if light_tween:
		light_tween.kill()
	var flash_tween := create_tween()
	flash_tween.tween_property(light, "energy", light_energy_full * 1.5, 0.05)
	flash_tween.tween_callback(func(): _set_light(color, light_energy_min, light_energy_max))


func _set_light(color: Color, energy_min: float, energy_max: float) -> void:
	if light == null:
		return
	light.color = color
	light.energy = energy_min
	light_tween = create_tween()
	light_tween.set_loops()
	light_tween.tween_property(light, "energy", energy_max, light_pulse_speed)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	light_tween.tween_property(light, "energy", energy_min, light_pulse_speed)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
