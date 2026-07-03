class_name ComboSystems
extends Node

## Adjust on how strong each usage is
@export var secondary_fire_cost: float = 80.0 # adjust to taste

## Returns true if the player can afford the secondary and deducts the cost
func try_spend_for_secondary() -> bool:
	if combo_strength < secondary_fire_cost:
		return false
	combo_strength -= secondary_fire_cost
	return true

@export_category("Combo Statistics")
@export var combo_level: int = 1
@export var combo_strength: float = 0
@onready var combo_count_ui: Label = $"../../InterfaceElements/NewHUD/UI/UpdatedComboCounter"
@onready var combo_reach_pulse: AnimationPlayer = $"../../InterfaceElements/NewHUD/UI/ComboReachFeedback/GlowEffect"
@export var max_combo : int = 1000

## Glow pulse
var combo_upgrade_feedback: bool = true
var combo_upgrade_feedback_two: bool = true
var combo_upgrade_feedback_three: bool = true
var combo_upgrade_feedback_four: bool = true

## Sets the bar's value for the combo meter
@export var combo_meter: ProgressBar

## This signal section sets the value of progress bars, usually
signal set_max_progress(max_prog: float)
signal set_current_progress(prog: float)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	combo_reach_pulse.play("LightPulse")
	_update_combo()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	## This combo decrement scales the higher the combo values are
	## which results in faster combo value dropping
	combo_strength -= (5) * delta
	if combo_strength < 0: combo_strength = 0
	_update_combo()
	pass
	#test

#region Custom functions for combo systems
# Function for incrementing combo meter, caps out to a certain point
func _add_combo_level(level_value) -> void:
	combo_strength += level_value
	if combo_strength >= max_combo : 
		combo_strength = max_combo
	return

func _subtract_combo_level() -> void:
	combo_strength -= 40
	if combo_strength >= max_combo : 
		combo_strength = max_combo
	return
	
# Function for updating the combo levels
func _update_combo() -> void:
	# Statements for combo levels
	
	if combo_strength < 100: 
		## This section emits the signals needed for the combo progress bar to function
		## This is also applicable for other elif statements
		#region Signal region
		set_current_progress.emit(combo_strength)
		set_max_progress.emit(100)
		#endregion
		combo_level = 1
		combo_upgrade_feedback = true
		
	elif combo_strength >= 100 and combo_strength <= 250:
		if combo_upgrade_feedback:
			combo_reach_pulse.play("LightPulse")
			combo_upgrade_feedback = false
		#region Signal region
		set_current_progress.emit(combo_strength - 100)
		set_max_progress.emit(150)
		#endregion		
		combo_level = 2
		combo_upgrade_feedback_two = true
		
	elif combo_strength >= 250 and combo_strength <= 450: 
		if combo_upgrade_feedback_two:
			combo_reach_pulse.play("LightPulse")
			combo_upgrade_feedback_two = false
		#region Signal region
		set_current_progress.emit(combo_strength - 250)
		set_max_progress.emit(200)
		#endregion		
		combo_level = 3
		combo_upgrade_feedback_three = true
		
	elif combo_strength >= 450 and combo_strength <= 700: 
		if combo_upgrade_feedback_three:
			combo_reach_pulse.play("LightPulse")
			combo_upgrade_feedback_three = false
		#region Signal region
		set_current_progress.emit(combo_strength - 450)
		set_max_progress.emit(300)
		#endregion		
		combo_upgrade_feedback_four = true		
		combo_level = 4

	elif combo_strength >= 750 and combo_strength:
		if combo_upgrade_feedback_four:
			combo_reach_pulse.play("LightPulse")
			combo_upgrade_feedback_four = false
		#region Signal region
		set_current_progress.emit(combo_strength - 750)
		set_max_progress.emit(500)
		#endregion				
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
