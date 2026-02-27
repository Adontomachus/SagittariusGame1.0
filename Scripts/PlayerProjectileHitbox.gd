class_name PlayerProjectileHitbox
extends Area2D

signal projectile_health_modify(modification: int)
signal score_modify(modification: int)

func modify_player_health(modification: int) -> void:
	print("Player is hit!")
	projectile_health_modify.emit(modification)
	
func modify_player_score(modification: int) -> void:
	print("Player gets xp!")
	score_modify.emit(modification)
