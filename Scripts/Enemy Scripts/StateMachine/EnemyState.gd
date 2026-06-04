extends Node
class_name EnemyState

@export var animation_name: String
@export var audio_to_play: AudioStream

@export var recovery_state: EnemyStateRecovery

#Test
@export var strafing_state: EnemyStateStrafing

var parent: Enemy
var animations: AnimationPlayer
var audio: AudioStreamPlayer2D
var beat_sync: BeatSync_Script

func enter() -> void:
	beat_sync = get_tree().get_first_node_in_group("BeatSync")
	if audio != null and audio_to_play != null:
		audio.stream = audio_to_play
		audio.play()
	
	if animations != null:
		animations.play_animation(animation_name)

func exit() -> void:
	if audio != null:
		audio.stop()

func process_frame(delta: float) -> EnemyState:
	return null

func process_physics(delta: float) -> EnemyState:
	return null
