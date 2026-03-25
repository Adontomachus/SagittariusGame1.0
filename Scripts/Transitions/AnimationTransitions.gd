extends Node

@export var transition_animation: AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	transition_animation.play("FadeInTransition")
	pass # Replace with function body.


	


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	get_tree().change_scene_to_file("res://Scenes/Interface/MainMenuScene.tscn")
	pass # Replace with function body.
