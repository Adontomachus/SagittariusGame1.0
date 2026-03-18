class_name CompanionStateMachine
extends Node

signal state_changed(state_name: String)

@export var starting_state: CompanionState
@export var sprite: Sprite2D
var current_state: CompanionState

func init(parent: Enemy, animations: AnimationPlayer = null, audio: AudioStreamPlayer2D = null):
	for child in get_children():
		child.parent = parent
		child.animations = animations
		child.audio = audio
	
	# Initialize to the default state
	change_state(starting_state)

# Change to the new state by first calling any exit logic on the current state.
func change_state(new_state: CompanionState) -> void:
	if current_state:
		current_state.exit()

	current_state = new_state
	current_state.enter()
	state_changed.emit(current_state.name)

func process_physics(delta: float) -> void:
	var new_state = current_state.process_physics(delta)
	if new_state:
		change_state(new_state)

func process_frame(delta: float) -> void:
	var new_state = current_state.process_frame(delta)
	if new_state:
		change_state(new_state)

func manual_state_override(new_state: CompanionState) -> void:
	change_state(new_state)
