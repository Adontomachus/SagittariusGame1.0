class_name SpearTelegraph
extends Node2D

@onready var telegraph_rect: ColorRect = $ColorRect

@export var telegraph_width: float = 90.0
@export var telegraph_length: float = 100000.0

var tween: Tween

@onready var telegraph_texture_rect: TextureRect = $TextureRect
@export var telegraph_texture: Texture2D


func _ready() -> void:
	telegraph_rect.size = Vector2(telegraph_width, telegraph_length)
	telegraph_rect.position = Vector2(-telegraph_width / 2.0, 0)
	telegraph_rect.color = Color(1.0, 0.5, 0.0, 0.0)  ## fully transparent, just for flash

	if telegraph_texture and telegraph_texture_rect:
		telegraph_texture_rect.texture = telegraph_texture
		telegraph_texture_rect.stretch_mode = TextureRect.STRETCH_SCALE
		telegraph_texture_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		telegraph_texture_rect.size = Vector2(telegraph_width, telegraph_length)
		telegraph_texture_rect.position = Vector2(-telegraph_width / 2.0, 0)
		telegraph_texture_rect.modulate = Color(1.0, 1.0, 1.0, 0.3)

	hide()

func show_charging() -> void:
	show()
	telegraph_rect.color = Color(1.0, 0.5, 0.0, 0.3)
	if tween:
		tween.kill()
	tween = create_tween()
	tween.set_loops()
	tween.tween_property(telegraph_rect, "color:a", 0.1, 0.2)
	tween.tween_property(telegraph_rect, "color:a", 0.4, 0.2)


func show_locked() -> void:
	if tween:
		tween.kill()
	## Flash red to warn player
	telegraph_rect.color = Color(1.0, 0.0, 0.0, 0.6)
	tween = create_tween()
	tween.set_loops()
	tween.tween_property(telegraph_rect, "color:a", 0.3, 0.1)
	tween.tween_property(telegraph_rect, "color:a", 0.8, 0.1)


func hide_telegraph() -> void:
	if tween:
		tween.kill()
	hide()


func track_player(enemy_pos: Vector2, player_pos: Vector2) -> void:
	global_position = enemy_pos
	var direction := (player_pos - enemy_pos).normalized()
	rotation = direction.angle() - PI / 2.0
