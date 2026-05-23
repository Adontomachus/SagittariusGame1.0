extends Control

## Signals for ending the gameplay or resuming the game while pausing
signal resume_game
signal exit_game

##@export var settingsMenu : Control


#region Button functions
func _on_resume_button_pressed() -> void:
	self.visible = false
	get_tree().paused = false
	Global.can_control_unit = true
	pass # Replace with function body.


func _on_exit_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Interface/MainMenuScene.tscn")
	pass # Replace with function body.

#endregion


func _on_settings_button_pressed() -> void:
	##settingsMenu.visible = true
	pass # Replace with function body.
