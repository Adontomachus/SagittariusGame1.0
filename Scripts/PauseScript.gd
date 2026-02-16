extends Control

func _resumeGame():
	get_tree().paused = false
	pass
	
func _pauseGame():
	get_tree().paused = true
	pass


func _on_resume_button_pressed() -> void:
	_resumeGame()
	pass # Replace with function body.
