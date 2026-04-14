extends Control

## Signals for ending the gameplay or resuming the game while pausing
signal resume_game
signal exit_game


#region Button functions
func _on_resume_button_pressed() -> void:
	resume_game.emit()
	pass # Replace with function body.


func _on_exit_button_pressed() -> void:
	exit_game.emit()
	pass # Replace with function body.

#endregion
