class_name ChargeShot
extends Node

@export var player: PlayerCharacter

@export_category("Charge Shot Stats")
## How many perfect hits to fill the charge
@export var max_shots_for_charged: int = 8
## Damage multiplier on top of base projectile damage
@export var damage_multiplier: float = 3.2
## Particle feedback threshold — shows particles when this many charges are built
@export var particle_threshold: int = 7
## A boolean for visual feedback for player UI, which would glow if charged shot is active
@export var can_fire_charged_shot: bool = false 

var shots_for_charged: int = 0
var powered_projectile := preload("res://Objects/Instances With Collision/EnhancedProjectile.tscn")


func is_charged() -> bool:
	return shots_for_charged >= max_shots_for_charged


func increment() -> void:
	shots_for_charged += 1
	_update_feedback()


func consume(modifier: float) -> bool:
	## Returns true if a charged shot was fired, false if not ready
	if not is_charged():
		return false

	var enhanced_projectile = powered_projectile.instantiate()
	player.shot_sound.play()
	enhanced_projectile.change_damage((player.projectile_damage * modifier) * damage_multiplier)
	enhanced_projectile.position = player.shot_point.get_global_position()
	enhanced_projectile.rotation_degrees = player.shot_point.rotation_degrees
	player.get_tree().get_root().call_deferred("add_child", enhanced_projectile)
	shots_for_charged = 0
	_update_feedback()
	return true


func _update_feedback() -> void:
	if shots_for_charged >= particle_threshold:
		can_fire_charged_shot = true
		player.charged_shot_particles.show()
	else:
		can_fire_charged_shot = false
		player.charged_shot_particles.hide()
