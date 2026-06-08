class_name EnemyStateWindup
extends EnemyState

@export var charging_state: EnemyState
@export var telegraph_animation: AnimationPlayer
@export var time_before_charging: float
@export var stomp_effect: PackedScene
@export var stomp_marker: Marker2D
@export var stomp_sound: AudioStreamPlayer
# For the camera shakes


var can_charge: bool

func enter() -> void:
	can_charge = false
	time_before_charging = 4
	telegraph_animation.play("Warning")
	print("Charging")
	
func process_physics(delta: float) -> EnemyState:
	## Creates a stomp effect every beat
	if GlobalBeatSync.executeAction:
		var stomp = stomp_effect.instantiate()
		stomp.position = stomp_marker.get_global_position()
		get_tree().get_root().call_deferred("add_child", stomp)
		stomp_sound.play()
		time_before_charging -= 1
	if time_before_charging <= 0:
		can_charge = true
	if 	can_charge:
		return charging_state
	return null
