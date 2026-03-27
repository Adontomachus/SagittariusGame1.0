class_name EnemyProjectileHitbox
extends Node

signal projectile_health_modify(modification: int)
signal display_damage_feedback(damage_value: int)

func modify_enemy_health(modification: int) -> void:
	projectile_health_modify.emit(modification)

func show_aoe_feedback(damage_value: int) -> void:
	display_damage_feedback.emit(damage_value)
