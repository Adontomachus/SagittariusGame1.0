class_name ComboSystems
extends Node

@export_category("Combo Statistics")
@export var combo_level: int = 1
@export var combo_strength: float = 0
@onready var combo_count_ui: Label = $"../../InterfaceElements/NewHUD/UI/UpdatedComboCounter"
@onready var combo_reach_pulse: AnimationPlayer = $"../../InterfaceElements/NewHUD/UI/ComboReachFeedback/GlowEffect"

## Glow pulse
var combo_upgrade_feedback: bool = true
var combo_upgrade_feedback_two: bool = true
var combo_upgrade_feedback_three: bool = true
var combo_upgrade_feedback_four: bool = true
## Green Pulse animation feedback for when the player's combo gets upgraded
# @onready var cssombo_reach_pulse: AnimationPlayer = $"../../InterfaceElements/NewHUD/UI/ComboReachPulse"


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	combo_reach_pulse.play("LightPulse")
	_update_combo()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	## This combo decrement scales the higher the combo values are
	## which results in faster combo value dropping
	combo_strength -= (25) * delta
	if combo_strength < 0: combo_strength = 0
	_update_combo()
	pass

#region Custom functions for combo systems
# Function for incrementing combo meter. Higher combos 
func _add_combo_level(level_value) -> void:
	combo_strength += level_value
	return
	
# Function for updating the combo levels
func _update_combo() -> void:
	# Statements for combo levels
	if combo_strength < 100: 
		combo_level = 1
		combo_upgrade_feedback = true
		
	elif combo_strength >= 100 and combo_strength <= 250:
		if combo_upgrade_feedback:
			combo_reach_pulse.play("LightPulse")
			combo_upgrade_feedback = false
		combo_level = 2
		combo_upgrade_feedback_two = true
		
	elif combo_strength >= 250 and combo_strength <= 450: 
		if combo_upgrade_feedback_two:
			combo_reach_pulse.play("LightPulse")
			combo_upgrade_feedback_two = false
		combo_level = 3
		combo_upgrade_feedback_three = true
		
	elif combo_strength >= 450 and combo_strength <= 700: 
		if combo_upgrade_feedback_three:
			combo_reach_pulse.play("LightPulse")
			combo_upgrade_feedback_three = false
		combo_upgrade_feedback_four = true		
		combo_level = 4
	elif combo_strength >= 750 and combo_strength:
		if combo_upgrade_feedback_four:
			combo_reach_pulse.play("LightPulse")
			combo_upgrade_feedback_four = false
		combo_level = 5
	match combo_level:
		1:
			combo_count_ui.text = "1x"
		2:
			combo_count_ui.text = "2x"
		3:
			combo_count_ui.text = "4x"
		4:
			combo_count_ui.text = "8x"
		5:
			combo_count_ui.text = "16x"
#endregion
