class_name PlayerProjectileHitbox
extends Area2D

var unit_hit_effect := preload("res://Objects/Particle Effects/Damaged Feedback/DamageFeedbackEffect.tscn") 

signal projectile_health_modify(modification: int)
signal score_modify(modification: int)
signal experience_modify(modification: int)

## Signal for Health Damaged Visuals
# signal shake_healthbar

## Animated visual feedback for experience gain
@export var xp_feedback: AnimationPlayer

func modify_player_health(modification: int) -> void:
	# shake_healthbar.emit()
	print("Player is hit!")
	# Hit feedback
	var hitEffect = unit_hit_effect.instantiate()
	projectile_health_modify.emit(modification)
	hitEffect.position = self.get_global_position()
	get_tree().get_root().call_deferred("add_child", hitEffect)

	
func modify_player_score(modification: int) -> void:
	print("Player gets points!")
	score_modify.emit(modification)
	
func modify_player_experience(modification: int) -> void:
	if xp_feedback: xp_feedback.play("Glow")
	print("Player gets xp!")
	experience_modify.emit(modification)
