class_name ComboSystems
extends Node

@export_category("Combo Statistics")
@export var combo_level: int = 5
@export var combo_strength: float = 0

@onready var combo_count_ui: Label = $"../../InterfaceElements/NewHUD/UI/UpdatedComboCounter"


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	_update_combo()
	pass

func _update_combo() -> void:
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
