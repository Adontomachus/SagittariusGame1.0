class_name MainMenuSystems

extends Node2D

# Panels for options
@export var settings: Control 
@export var tutorial: Control
# Main menu container
@export var main_menu: MarginContainer
@export var main_menu_transition: AnimationPlayer

@export var loading_screen_scene: PackedScene

func _ready() -> void:
	# Stops the time pause which plays the animation again
	get_tree().paused = false
	
	#main_menu_transition.play("MainMenuTransitions")

func _on_start_button_pressed() -> void:
	ScalingSystemScript.reset_scaling()
	_load_scene("res://Scenes/Gameplay/GameplayScene.tscn")

func _load_scene(path: String) -> void:
	## Instantiate loading screen and add it to the tree
	var loading_screen := loading_screen_scene.instantiate() as LoadingScreen
	loading_screen.scene_to_load = path
	get_tree().current_scene.add_child(loading_screen)

	## Hide the main menu while loading
	main_menu.visible = false

func _on_story_mode_pressed() -> void:
	OS.shell_open("https://www.halohaloapp.com")
	#get_tree().change_scene_to_file("res://Scenes/Gameplay/GameplayScene.tscn")
	#ScalingSystemScript.reset_scaling()
	#pass # Replace with function body.

func _on_settings_button_pressed() -> void:
	settings.visible = true
	pass # Replace with function body.


func _on_calibration_button_pressed() -> void:
	tutorial.visible = true
	main_menu.visible = false
	pass # Replace with function body.


func _on_exit_button_pressed() -> void:
	get_tree().quit()
	pass # Replace with function body.
	
func _on_settings_back_button_pressed() -> void:
	pass

func _on_select_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Interface/LevelSelect.tscn")
