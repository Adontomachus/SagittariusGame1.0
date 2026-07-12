class_name SpearTelegraph
extends Node2D

@onready var telegraph_rect: ColorRect = $ColorRect

@export var telegraph_width: float = 90.0
@export var telegraph_length: float = 100000.0

var tween: Tween
@onready var lava := $Sprite2D
@onready var telegraph_texture_rect: Sprite2D = $TextureRect
@export var telegraph_texture: Texture2D

@onready var lava_line: Line2D = $LavaLine


func _ready() -> void:
	telegraph_rect.size = Vector2(telegraph_width, telegraph_length)
	telegraph_rect.position = Vector2(-telegraph_width / 2.0, 0)
	telegraph_rect.color = Color(1.0, 0.5, 0.0, 0.0)

	lava_line.width = telegraph_width * 2
	lava_line.clear_points()
	lava_line.scale = Vector2(1.0, 0.5)
	lava_line.add_point(Vector2.ZERO)
	lava_line.add_point(Vector2(0, telegraph_length))

	lava_line.modulate = Color(1,1,1,0.3)

	hide()

func show_charging():
	show()

	if tween:
		tween.kill()

	telegraph_rect.color = Color(1,0.5,0,0.2)
	lava_line.modulate.a = 0.8

	tween = create_tween()
	tween.set_loops()

	tween.parallel().tween_property(
		telegraph_rect,
		"color:a",
		0.05,
		0.2
	)

	tween.parallel().tween_property(
		lava_line,
		"modulate:a",
		1,
		0.2
	)

	tween.parallel().tween_property(
		telegraph_rect,
		"color:a",
		0.3,
		0.2
	)

	tween.parallel().tween_property(
		lava_line,
		"modulate:a",
		.9,
		0.2
	)


func show_locked():
	if tween:
		tween.kill()

	lava_line.modulate = Color(1.2,0.3,0.3,0.8)

	tween = create_tween()
	tween.set_loops()

	tween.tween_property(lava_line,"modulate:a",1.0,0.08)
	tween.tween_property(lava_line,"modulate:a",0.4,0.08)


func hide_telegraph() -> void:
	if tween:
		tween.kill()
	hide()


func track_player(enemy_pos: Vector2, player_pos: Vector2) -> void:
	global_position = enemy_pos
	var direction := (player_pos - enemy_pos).normalized()
	rotation = direction.angle() - PI / 2.0
