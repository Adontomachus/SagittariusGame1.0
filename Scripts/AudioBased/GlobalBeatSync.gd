extends Node

var executeAction : bool = false
var beat: float
var lastBeat = 0

#region This is for every note that has passed in order to sync events at varying note values
var notesPassed: int
var measuresPassed: int
var halfNotesPassed: int
var quarterNotesPassed: int

# TEMPORARY
var currentNote = 0

func _ready() -> void:
	return

func _process(delta: float) -> void:
	if executeAction == true:
		_execute_action_on_beat()
		executeAction = false
	if notesPassed >= 4:
		notesPassed = 0
		print("Bar passed!")
		measuresPassed += 1
	if measuresPassed >= 4:
		measuresPassed = 0
	return
	
func _execute_action_on_beat():
	return
	
