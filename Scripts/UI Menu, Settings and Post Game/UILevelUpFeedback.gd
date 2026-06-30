extends Label


@export var animation_player: AnimationPlayer


func play_levelup_animation() -> void:
	animation_player.play("LevelUp")
