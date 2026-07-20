class_name SecondaryFire_Script
extends Node

enum SecondaryType {
	NONE,
	DASH,
	GRENADE
}

var equipped_upgrade: UpgradeData

@export_category("Secondary Type")
@export var secondary_type: SecondaryType = SecondaryType.NONE

@export var player: PlayerCharacter
@export var beat_sync: BeatSync_Script
@export var combo_system: ComboSystems

@export_category("Secondary Stats")
@export var good_hit_window: float = 0.15

@export_category("Dash Settings")
@export var dash_force: float = 1600.0
@export var dash_duration: float = 0.15

@export_category("Grenade Settings")
@export var grenade_scene: PackedScene

var secondary_actions: Dictionary = {}


func _ready() -> void:
	pass


func _input(event: InputEvent) -> void:
	if secondary_type == SecondaryType.NONE:
		return
	if not beat_sync.level_song.playing:
		return
	if beat_sync.beat_consumed:
		return
	if event.is_action_pressed("secondary_fire"):
		_try_secondary(_get_timing())


func _get_timing() -> float:
	var beat_fraction := fmod(beat_sync.beat_precise, 1.0)
	var full_beat_timing: float = min(abs(beat_fraction), abs(1.0 - beat_fraction))
	var half_beat_timing: float = abs(0.5 - beat_fraction)
	return min(full_beat_timing, half_beat_timing)


func _try_secondary(timing: float) -> void:
	if timing > good_hit_window:
		print("Secondary miss — timing: ", timing)
		return
	if not combo_system.try_spend_for_secondary():
		print("Not enough combo for secondary — need: ", combo_system.secondary_fire_cost)
		return
	print("Secondary hit — type: ", SecondaryType.keys()[secondary_type], " | timing: ", timing)
	match secondary_type:
		SecondaryType.DASH:
			_dash()
		SecondaryType.GRENADE:
			_grenade()


func set_secondary(type: SecondaryType) -> void:
	secondary_type = type
	if type == SecondaryType.NONE:
		secondary_actions.clear()
	else:
		secondary_actions["secondary_fire"] = true


func _dash() -> void:
	var dash_direction := Vector2(
		Input.get_axis("move_left", "move_right"),
		Input.get_axis("move_up", "move_down")
	).normalized()

	if dash_direction == Vector2.ZERO:
		dash_direction = (player.get_global_mouse_position() - player.global_position).normalized()

	player.velocity += dash_direction * dash_force
	player.is_dashing = true
	player.dash_velocity = player.velocity

	await player.get_tree().create_timer(dash_duration).timeout
	player.is_dashing = false
	player.dash_velocity = Vector2.ZERO


func _grenade() -> void:
	if not player.grenade_ready:
		print("Grenade on cooldown")
		return

	var scene := grenade_scene if grenade_scene else player.grenade_scene
	if scene == null:
		push_error("SecondaryFire: no grenade_scene assigned")
		return

	var grenade = scene.instantiate()
	player.get_tree().get_root().call_deferred("add_child", grenade)

	grenade.explosion_damage = player.grenade_damage / (
		randf_range(player.grenade_damage_divisor_min, player.grenade_divisor_max)
	)
	grenade.explosion_radius = player.grenade_radius

	await player.get_tree().process_frame
	grenade.launch(player.global_position, player.get_global_mouse_position())

	player.grenade_ready = false
	await player.get_tree().create_timer(player.grenade_cooldown).timeout
	player.grenade_ready = true

## Register new secondaries below — add to enum and match block above
