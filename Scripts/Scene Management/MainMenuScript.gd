class_name MainMenuSystems

extends Node2D

# Panels for options
@export var settings: Control 
@export var tutorial: Control
# Main menu container
@export var main_menu: MarginContainer
@export var main_menu_transition: AnimationPlayer

func _ready() -> void:
	# Stops the time pause which plays the animation again
	get_tree().paused = false
	
	main_menu_transition.play("MainMenuTransitions")

func _on_start_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Gameplay/GameplayScene.tscn")
	pass # Replace with function body.

func _on_story_mode_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Gameplay/GameplayScene.tscn")
	pass # Replace with function body.

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
