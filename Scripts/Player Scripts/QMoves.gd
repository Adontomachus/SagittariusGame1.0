class_name QMoves
extends Node

signal player_ability_pulse

@export var player: PlayerCharacter
@export var beat_sync: BeatSync_Script

## Ability stats — editable per upgrade
@export_category("Ability Stats")
@export var damage_divisor_min: float = 1.4
@export var damage_divisor_max: float = 1.6
@export var ability_duration_beats: int = 20

var ability_active: bool = false
var ability_duration: int = 0

var pulse_aoe := preload("res://Objects/Instances With Collision/SplashDamage.tscn")


func _ready() -> void:
	pass


## Called by your existing ability input check
func activate() -> void:
	if ability_active:
		return
	ability_duration = ability_duration_beats
	ability_active = true
	player.ability_aoe_node.show()


## Call this every beat from GlobalBeatSync or BeatSync signal
func on_beat() -> void:
	if not ability_active:
		return
	ability_duration -= 1
	## Spawn AoE directly here instead of signaling back to player
	var aoe_damage = pulse_aoe.instantiate()
	player.pulse_sound_effect.play()
	aoe_damage.change_damage(player.projectile_damage / randf_range(damage_divisor_min, damage_divisor_max))
	aoe_damage.position = player.shot_point.get_global_position()
	player.get_tree().get_root().call_deferred("add_child", aoe_damage)
	if ability_duration <= 0:
		player.ability_aoe_node.hide()
		ability_active = false


## Register new Q move beloww
