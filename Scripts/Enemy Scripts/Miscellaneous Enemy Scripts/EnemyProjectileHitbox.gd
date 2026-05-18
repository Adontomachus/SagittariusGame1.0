class_name EnemyProjectileHitbox
extends Node

@export var damage_flash_effect: AnimationPlayer

signal projectile_health_modify(modification: int)

## CONNECT the display damage signal to AoE feedback function from the enemy s
## for AoE damage feedback to instantiate properly
signal display_damage_feedback(damage_value: int)

func modify_enemy_health(modification: int) -> void:
	projectile_health_modify.emit(modification)
	if damage_flash_effect:
		if damage_flash_effect.is_playing():
			damage_flash_effect.stop(true)
			damage_flash_effect.play("Flash")
		else:
			damage_flash_effect.play("Flash")


func show_aoe_feedback(damage_value: int) -> void:
	display_damage_feedback.emit(damage_value)
	if damage_flash_effect:
		if damage_flash_effect.is_playing():
			damage_flash_effect.stop(true)
			damage_flash_effect.play("Flash")
		else:
			damage_flash_effect.play("Flash")
