extends Node

@onready var pulse_feedback_effect: AnimationPlayer = $PulseFeedbackEffect

func _pulse_to_beat() -> void:
	pulse_feedback_effect.play("BeatIndicatorEffect")
	pass
