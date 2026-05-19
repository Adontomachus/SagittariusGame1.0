extends Node

#Level Player is currently at
var currentLevel: int = 1

# Max level unlocked by the player
var levelUnlocked: int = 1

# Maximum number of levels
var maxLevel: int = 3

# Unlocks levels
func _unlock_level(levelToUnlock: int) -> void:
	if levelToUnlock > levelUnlocked:
		levelUnlocked = levelToUnlock

func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Interface/MainMenuScene.tscn")

func _load_level(levelToLoad: int) -> void:
	if levelToLoad > maxLevel:
		# When players have reached max level and are done with it
		# Go to credits
		get_tree().change_scene_to_file("res://Scenes/Interface/MainMenuScene.tscn")
	print("I am the Level Select trying to access", str("res://Scenes/Maps and Levels/Level", levelToLoad, ".tscn"))
	get_tree().change_scene_to_file(str("res://Scenes/Maps and Levels/Level", levelToLoad, ".tscn"))
