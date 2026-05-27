extends Control

@export_category("Main Menu node to set visible")
@export var main_menu_node: MarginContainer

@onready var easy: CheckBox  = $"VBoxContainer/DifficultyContainer/HBoxContainer/EasyBox"
@onready var medium: CheckBox = $"VBoxContainer/DifficultyContainer/HBoxContainer/MediumBox"
@onready var hard: CheckBox = $"VBoxContainer/DifficultyContainer/HBoxContainer/HardBox"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var difficultySettings = SaveSettings._load_difficulty_settings()
	var videoSettings = SaveSettings._load_video_settings()
	var difficulty_settings = SaveSettings._load_difficulty_settings()
	match difficulty_settings:
		0:
			easy.button_pressed = true
			medium.button_pressed = false
			hard.button_pressed = false
		1:
				easy.button_pressed = false
				medium.button_pressed = true
				hard.button_pressed = false
		2:
				easy.button_pressed = false
				medium.button_pressed = false
				hard.button_pressed = true

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
	var difficulty := 0
	if medium.button_pressed:
		difficulty = 1
	elif hard.button_pressed:
		difficulty = 2
	SaveSettings._save_difficulty_settings("difficulty", difficulty)
	print("Saved Succesfully")
