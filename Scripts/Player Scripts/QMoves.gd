class_name QMoves
extends Node

# Add here names of new moves
enum AbilityType {Q_NONE ,AOE_PULSE, DIRECTIONAL_CONE }

@export_category("Ability Type")
@export var ability_type: AbilityType = AbilityType.Q_NONE

@export var player: PlayerCharacter
@export var beat_sync: BeatSync_Script

@export_category("Ability Stats")
@export var damage_divisor_min: float = 1.2
@export var damage_divisor_max: float = 1.5
# How many (half)beats the ability activates
@export var ability_duration_beats: int = 26

@export_category("Directional Cone Settings")
@export var cone_projectile_count: int = 5
@export var cone_spread_degrees: float = 45.0
@export var cone_damage_modifier: float = 0.8

var ability_active: bool = false
var ability_duration: int = 0

var pulse_aoe := preload("res://Objects/Instances With Collision/SplashDamage.tscn")
var projectile := preload("res://Objects/Instances With Collision/PrototypeProjectile.tscn")


func _ready() -> void:
	pass

func activate() -> void:
	if ability_active:
		return
	ability_duration = ability_duration_beats
	ability_active = true
	player.ability_aoe_node.show()


func on_beat() -> void:
	if not ability_active:
		return
	ability_duration -= 1

	match ability_type:
		AbilityType.AOE_PULSE:
			_fire_aoe_pulse()
		AbilityType.DIRECTIONAL_CONE:
			_fire_directional_cone()

	if ability_duration <= 0:
		player.ability_aoe_node.hide()
		ability_active = false


func _fire_aoe_pulse() -> void:
	var aoe_damage = pulse_aoe.instantiate()
	player.pulse_sound_effect.play()
	aoe_damage.change_damage(player.projectile_damage / randf_range(damage_divisor_min, damage_divisor_max))
	aoe_damage.position = player.shot_point.get_global_position()
	player.get_tree().get_root().call_deferred("add_child", aoe_damage)


func _fire_directional_cone() -> void:
	var mouse_dir := (player.get_global_mouse_position() - player.shot_point.get_global_position()).normalized()
	var base_angle := mouse_dir.angle()
	var half_spread := deg_to_rad(cone_spread_degrees / 2.0)
	var step :float = deg_to_rad(cone_spread_degrees) / max(cone_projectile_count - 1, 1)

	player.shot_sound.play()
	for i in range(cone_projectile_count):
		var angle_offset := -half_spread + step * i
		var proj = projectile.instantiate()
		proj.change_damage(player.projectile_damage * cone_damage_modifier)
		proj.change_projectile_side(ProjectileCommon.ProjectileSide.Player)
		proj.position = player.shot_point.get_global_position()
		proj.rotation = base_angle + angle_offset
		player.get_tree().get_root().call_deferred("add_child", proj)

## Register new Q moves below
