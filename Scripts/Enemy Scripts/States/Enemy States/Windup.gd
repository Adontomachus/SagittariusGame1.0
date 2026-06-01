class_name EnemyStateWindup
extends EnemyState

@export var charging_state: EnemyState
@export var telegraph_animation: AnimationPlayer
@export var time_before_charging: float
var can_charge: bool

func enter() -> void:
	can_charge = false
	time_before_charging = 2
	telegraph_animation.play("Warning")
	await get_tree().create_timer(2).timeout
	can_charge = true
	print("Charging")
	
func process_physics(delta: float) -> EnemyState:
	time_before_charging -= 1 * delta
	if 	can_charge:
		return charging_state
	return null
