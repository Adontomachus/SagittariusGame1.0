class_name EliteDecideState
extends EnemyState

@export var shoot_state: EnemyStateShoot
@export var spear_state: EliteSpearChargeState

## 0.0 to 1.0 — chance of picking spear over shoot
@export var spear_chance: float = 0.5


func enter() -> void:
	super()


func process_frame(_delta: float) -> EnemyState:
	## Pick immediately
	if randf() <= spear_chance:
		return spear_state
	else:
		return shoot_state


func exit() -> void:
	pass
