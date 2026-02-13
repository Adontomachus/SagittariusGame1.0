extends Node2D

@onready var beatIndicator: Panel = $HUD/BeatIndicator

@onready var animation_player: AnimationPlayer = beatIndicator.get_node("AnimationPlayer")

func _ready():
	animation_player.play("Pulse")
