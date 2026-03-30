class_name ComboSystems
extends Node

@export_category("Combo Statistics")
@export var combo_level: int = 1
@export var combo_strength: float = 0

@onready var combo_count_ui: Label = $"../../InterfaceElements/NewHUD/UI/UpdatedComboCounter"


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_update_combo()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	## This combo decrement scales the higher the combo values are
	## which results in faster combo value dropping
	combo_strength -= (20 - combo_strength / 50) * delta
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
	if combo_strength < 100: combo_level = 1
	elif combo_strength >= 100 and combo_strength <= 250: combo_level = 2
	elif combo_strength >= 250 and combo_strength <= 450: combo_level = 3
	elif combo_strength >= 450 and combo_strength <= 700: combo_level = 4
	elif combo_strength >= 750 and combo_strength: combo_level = 5
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
