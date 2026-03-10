class_name MainMenuSystems

extends Node2D



func _on_start_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Gameplay/GameplayScene.tscn")
	pass # Replace with function body.

func _on_story_mode_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Gameplay/GameplayScene.tscn")
	pass # Replace with function body.

func _on_settings_button_pressed() -> void:
	pass # Replace with function body.


func _on_calibration_button_pressed() -> void:
	pass # Replace with function body.


func _on_exit_button_pressed() -> void:
	pass # Replace with function body.
