extends Control

@export_category("Main Menu node to set visible")
@export var main_menu_node: MarginContainer

@export var easy: CheckBox
@export var medium: CheckBox
@export var hard: CheckBox 


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var difficulty = SaveSettings._load_difficulty()
	print("Difficulty: ", difficulty)
	print(easy)
	print(medium)
	print(hard)
	if(difficulty == 0):
		easy.button_pressed = true
	elif(difficulty == 1):
		medium.button_pressed = true
	else:
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
		
	var difficulty
	
	if medium.button_pressed:
		difficulty = 1
	elif hard.button_pressed:
		difficulty = 2
	else:
		difficulty = 0  # default easy
	
	SaveSettings._save_difficulty_settings("difficulty", difficulty)
	
	print("Saved Succesfully")
