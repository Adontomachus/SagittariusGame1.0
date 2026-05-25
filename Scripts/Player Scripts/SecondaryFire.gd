class_name SecondaryFire_Script
extends Node

## Signals
signal player_dash

@export var beat_sync: BeatSync_Script

@export var good_hit_window: float = 0.07

#region Secondary Action Registry\
## To add a new secondary: register it in _ready()
var secondary_actions: Dictionary = {}
#endregion

func _ready() -> void:
	var player = get_tree().get_first_node_in_group("PlayerObject")
	player_dash.connect(player._dash)
	
	# Register secondary actions here
	secondary_actions["secondary_fire"] = _secondary_dash
	# Add new Secondary fires below
	
func _input(event: InputEvent) -> void:
	if not beat_sync.level_song.playing:
		return
		
	for action in secondary_actions:
		if event.is_action_pressed(action):
			_try_secondary(action, _get_timing())
		
func _get_timing() -> float:
	var beat_fraction := fmod(beat_sync.beat_precise, 1.0)
	var full_beat_timing: float = min(abs(beat_fraction), abs(1.0 - beat_fraction))
	var half_beat_timing: float = abs(0.5 - beat_fraction)
	return min(full_beat_timing, half_beat_timing)
	
func _try_secondary(action: String, timing: float) -> void:
	if timing > good_hit_window:
		print("Secondary miss — timing: ", timing)
		return
	print("Secondary hit — action: ", action, " | timing: ", timing)
	secondary_actions[action].call(timing)
	
# Secondary skill example
func _secondary_dash(_timing: float) -> void:
	## _timing passed so that we can add timing based rewards later
	player_dash.emit()

# Add future dexondary skills below
