extends Node


var max_health_amount: int
var current_health_amount: int
@export var health_text: Label

# This is for 
@export var player_object: PlayerCharacter

# Called when the node enters the scene tree for the first time.
func _process(delta: float):
	if player_object:
		_update_experience_text()
	pass

func _update_experience_text() -> void:
	current_health_amount = player_object.healthPoints 
	max_health_amount = player_object.maxHealthPoints
	health_text.text = str(current_health_amount) + " | " + str(max_health_amount) + " Health"
	pass
