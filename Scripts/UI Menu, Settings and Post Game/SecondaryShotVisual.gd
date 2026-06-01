extends Node

var shot_bars: Array[TextureRect]
@export var shots_available: = 2
@export var pulse_animation: AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var bar_parent = $HBoxContainer
	for child in bar_parent.get_children():
		shot_bars.append(child)
	pass # Replace with function body.

func _update_shot_counter() -> void:
	for i in range(shot_bars.size()):
		shot_bars[i].visible = i < shots_available

func _pulse_with_beat() -> void:
	pulse_animation.play("Pulse")
	

func _process(delta) -> void:
	if GlobalBeatSync.lastBeat < GlobalBeatSync.beat:
		_pulse_with_beat()
	_update_shot_counter()
	pass
