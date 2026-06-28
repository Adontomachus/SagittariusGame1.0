class_name MinimapDotLayer
extends Control

@export var minimap: Minimap

var player_color: Color = Color.CYAN
var enemy_color: Color = Color.RED
var player_dot_size: float = 6.0
var enemy_dot_size: float = 4.0


func _ready() -> void:
	if minimap == null:
		minimap = get_parent().get_parent()
	player_color = minimap.player_color
	enemy_color = minimap.enemy_color
	player_dot_size = minimap.player_dot_size
	enemy_dot_size = minimap.enemy_dot_size


func _draw() -> void:
	if minimap == null or minimap.player == null:
		return

	var center := size / 2.0
	var radius := size.x / 2.0

	var enemies := get_tree().get_nodes_in_group("GeneralEnemyInstance")
	for enemy in enemies:
		var dot_pos := minimap.world_to_minimap(enemy.global_position)
		dot_pos = _clamp_to_circle(dot_pos, center, radius, enemy_dot_size)
		draw_circle(dot_pos, enemy_dot_size, enemy_color)

	draw_circle(center, player_dot_size, player_color)

	var mouse_dir := (minimap.player.get_global_mouse_position() - minimap.player.global_position).normalized()
	var arrow_end := center + mouse_dir * (player_dot_size + 6.0)
	draw_line(center, arrow_end, player_color, 2.0)


func _clamp_to_circle(point: Vector2, center: Vector2, radius: float, dot_size: float) -> Vector2:
	var offset := point - center
	var dist := offset.length()
	var max_dist := radius - dot_size
	if dist > max_dist:
		return center + offset.normalized() * max_dist
	return point
