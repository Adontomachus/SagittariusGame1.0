class_name EnemyProjectileHitbox
extends Node

signal projectile_health_modify(modification: int)

func modify_enemy_health(modification: int) -> void:
	projectile_health_modify.emit(modification)