class_name PlayerProjectileHitbox
extends Node

signal projectile_health_modify(modification: int)

func modify_player_health(modification: int) -> void:
	projectile_health_modify.emit(modification)
