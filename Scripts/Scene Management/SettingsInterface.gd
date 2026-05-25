extends Control

@export_category("Main Menu node to set visible")
@export var main_menu_node: MarginContainer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var difficultySettings = SaveSettings._load_difficulty_settings()
	var videoSettings = SaveSettings._load_video_settings()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_back_button_pressed() -> void:
	self.visible = false


func _on_confirmation_button_pressed() -> void:
	for slider in get_tree().get_nodes_in_group("VolumeSlider"):
		SaveSettings._save_volume_settings(
		slider.audio_bus_name, 
		slider._get_volume()
		) 
	print("Saved Succesfully")
