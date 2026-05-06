extends Node

@export_category("Main Player Beat Synchronization")
@export var beat_sync_script: BeatSync_Script
@export var game_manager: GManager


var accuracy_percentage: float
var total_maximum_accuracy: float
var total_accuracy: float

## This section is the declaration of labels in a Lose Interface scene
@export var highest_level_reached: Label
@export var damage_dealt: Label
@export var score_stats: Label
@export var rhythm_accuracy: Label
@export var exit_button: Button
@export var resume_button: Button

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	score_stats.text = "Total Score: " + str(PointSystemScript.playerScore)
	damage_dealt.text = "Total Damage Given: " + str(PointSystemScript.total_damage_dealt)
	#beat_sync_script.accuracy = total_accuracy
	#beat_sync_script.total_accuracy = total_maximum_accuracy
	#accuracy_percentage = (total_accuracy / total_maximum_accuracy) * 100
	# rhythm_accuracy.text = "Timing Accuracy: " + str(accuracy_percentage)
	pass


func on_win_press() -> void:
	get_tree().change_scene_to_file("res://Scenes/Interface/MainMenuScene.tscn")
	pass # Replace with function body.pass # Replace with function body.


func on_lose_press() -> void:
	get_tree().change_scene_to_file("res://Scenes/Interface/MainMenuScene.tscn")
	pass # Replace with function body.
