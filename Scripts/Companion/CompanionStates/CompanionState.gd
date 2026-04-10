extends Node
class_name CompanionState

@export var animation_name: String
@export var audio_to_play: AudioStream

# @export var stationary_state: CompanionStateStationary

#Test
# @export var strafing_state: EnemyStateStrafing

var parent: CompanionGroup
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

func process_frame(delta: float) -> CompanionState:
	return null

func process_physics(delta: float) -> CompanionState:
	return null
