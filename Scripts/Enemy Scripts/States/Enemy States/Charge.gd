class_name EnemyStateCharge
extends EnemyState

@export var after_chase_state: EnemyState
@export var charge_timer: float = 2
@export var charge_sound: AudioStreamPlayer
var current_charge_timer: float

func enter() -> void:
	charge_sound.play()
	current_charge_timer = charge_timer
	super()

func process_physics(delta: float) -> EnemyState:
	parent.movement_boosted = true
	parent.navAgent.target_position = parent.target.global_position
	parent.move_enemy(delta)
	## Creates a stomp effect every beat
	if GlobalBeatSync.lastBeat < GlobalBeatSync.beat:
		current_charge_timer -= 1
		
	if current_charge_timer <= 0:
		parent.movement_boosted = false
		parent.currentMoveSpeed = parent.maxMoveSpeed
		return after_chase_state

	#if parent.navAgent.is_navigation_finished() and after_chase_state:
	#	parent.currentMoveSpeed = parent.maxMoveSpeed
	#	return after_chase_state

	return null
