extends Node


var max_experience_amount_needed: int
var current_experience: int
@export var experience_text: Label

# This is for 
@export var player_object: PlayerCharacter

# Called when the node enters the scene tree for the first time.
func _process(delta: float):
	if player_object:
		_update_experience_text()
	pass

func _update_experience_text() -> void:
	current_experience = player_object.experiencePoints 
	max_experience_amount_needed = player_object.maxExperiencePoints
	experience_text.text = str(current_experience) + " | " + str(max_experience_amount_needed) + " XP"
	pass
