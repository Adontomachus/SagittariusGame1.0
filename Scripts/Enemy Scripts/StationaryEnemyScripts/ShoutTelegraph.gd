class_name ShoutTelegraph
extends Node2D

## For animation
#@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var warning_sprite: Sprite2D = $Sprite2D
@export var radius: float = 200
@onready var spin_animation: AnimationPlayer = $SpinAnimation

var tween: Tween

@export var isometric_y_scale: float = 0.5


func _ready() -> void:
	scale.y = isometric_y_scale

func show_warning(duration: float) -> void:
	spin_animation.play("Spinning")
	# var texture_half_size: float = warning_sprite.texture.get_size().x / 2.0
	# warning_sprite.scale = Vector2(radius/ texture_half_size, radius/ texture_half_size)
	# warning_sprite.modulate = Color(1.0, 0.3, 0.3, 0.6)
	## Pulse the warning opacity over the travel time
	tween = create_tween()
	tween.set_loops()
	tween.tween_property(warning_sprite, "modulate:a", 1.0, duration * 0.3)
	tween.tween_property(warning_sprite, "modulate:a", 0.4, duration * 0.3)
