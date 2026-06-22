class_name EnemyProjectileHitbox
extends Node

@export var damage_flash_effect: AnimationPlayer

signal projectile_health_modify(modification: int)

## CONNECT the display damage signal to AoE feedback function from the enemy
## for AoE damage feedback to instantiate properly
signal display_damage_feedback(damage_value: int)

## CONNECT the stacking damage signal to AoE feedback function from the enemy
## for the stacking damage visuals to show up properly
signal stacking_feedback(damage_value: int)

## CONNECT the tick damage signal to AoE feedback function from the enemy
## for the tick damage visuals to show up properly
signal tick_damage_feedback(damage_value: int)

## For the usual damage type inflicted on enemy
func modify_enemy_health(modification: int) -> void:
	projectile_health_modify.emit(modification)
	if damage_flash_effect:
		if damage_flash_effect.is_playing():
			damage_flash_effect.stop(true)
			damage_flash_effect.play("Flash")
		else:
			damage_flash_effect.play("Flash")

## For tick-type inflicted damage
func modify_enemy_health_tick(modification: int) -> void:
	projectile_health_modify.emit(modification)
	if damage_flash_effect:
		if damage_flash_effect.is_playing():
			damage_flash_effect.stop(true)
			damage_flash_effect.play("Flash")
		else:
			damage_flash_effect.play("Flash")


func show_aoe_feedback(damage_value: int) -> void:
	display_damage_feedback.emit(damage_value)
	tick_damage_feedback.emit(damage_value)
	stacking_feedback.emit(damage_value)
	if damage_flash_effect:
		if damage_flash_effect.is_playing():
			damage_flash_effect.stop(true)
			damage_flash_effect.play("Flash")
		else:
			damage_flash_effect.play("Flash")
