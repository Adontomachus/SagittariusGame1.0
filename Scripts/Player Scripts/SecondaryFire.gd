class_name SecondaryFire_Script
extends Node

## Signals
signal player_dash
signal player_grenade

var equipped_upgrade: UpgradeData

@export var beat_sync: BeatSync_Script
@export var combo_system: ComboSystems

@export var good_hit_window: float = 0.15

#region Secondary Action Registry\
## To add a new secondary: register it in _ready()
var secondary_actions: Dictionary = {}
#endregion

func _ready() -> void:
	var player = get_tree().get_first_node_in_group("PlayerObject")
	player_dash.connect(player._dash)
	player_grenade.connect(player._grenade)
	
	# Register secondary actions here
	#secondary_actions["secondary_fire"] = _secondary_dash
	# Add new Secondary fires below
	#secondary_actions["secondary_fire"] = _secondary_grenade
	
func _input(event: InputEvent) -> void:
	if not beat_sync.level_song.playing:
		return
	if beat_sync.beat_consumed:      # block if primary already fired
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
	if not combo_system.try_spend_for_secondary():
		print("Not enough combo to use secondary — need: ", combo_system.secondary_fire_cost)
		return
	print("Secondary hit — action: ", action, " | timing: ", timing)
	secondary_actions[action].call(timing)
	
# Secondary skills
func _secondary_dash(_timing: float) -> void:
	player_dash.emit()

func _secondary_grenade(_timing: float) -> void:
	player_grenade.emit()
# Add future dexondary skills below
