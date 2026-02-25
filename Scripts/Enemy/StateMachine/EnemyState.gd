extends Node
class_name EnemyState

@export var animation_name: String
@export var audio_to_play: AudioStream

@export var recovery_state: EnemyStateRecovery

var parent: Enemy
var animations: AnimationPlayer
var audio: AudioStreamPlayer2D

func enter() -> void:
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
