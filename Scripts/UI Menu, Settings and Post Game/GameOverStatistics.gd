extends Node

@export_category("Main Player Beat Synchronization")
@export var beat_sync_script: BeatSync_Script

var accuracy_percentage: float
var total_maximum_accuracy: float
var total_accuracy: float

## This section is the declaration of labels in a Lose Interface scene
@onready var highest_level_reached: Label = $BigLoseText/HighestLevelReached
@onready var damage_dealt: Label = $BigLoseText/DamageDealt
@onready var score_stats: Label = $BigLoseText/ScoreStats
@onready var rhythm_accuracy: Label = $BigLoseText/RhythmAccuracy
@onready var exit_button: Button = $BigLoseText/ExitButton
@onready var resume_button: Button = $BigLoseText/ResumeButton

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	beat_sync_script.accuracy = total_accuracy
	beat_sync_script.total_accuracy = total_maximum_accuracy
	accuracy_percentage = total_accuracy / total_maximum_accuracy * 100
	rhythm_accuracy.text = "Timing Accuracy: " + str(accuracy_percentage)
	pass
