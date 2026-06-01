class_name Minimap
extends CanvasLayer

@export var minimap_size: Vector2 = Vector2(200, 200)

## Dot colors
@export var player_color: Color = Color.CYAN
@export var enemy_color: Color = Color.RED

## Dot sizes
@export var player_dot_size: float = 6.0
@export var enemy_dot_size: float = 4.0

## Your level bounds — set to match your actual level
@export var level_origin: Vector2 = Vector2(0, 0)
@export var level_size: Vector2 = Vector2(3000, 3000)

@onready var dot_layer: Control = $MinimapContainer/MinimapDotLayer

var player: PlayerCharacter


func _ready() -> void:
	player = get_tree().get_first_node_in_group("PlayerObject")

	## Force SubViewport to share the main scene's World2D
	var viewport := $MinimapContainer/SubViewportContainer/SubViewport
	viewport.world_2d = get_viewport().world_2d

	await get_tree().process_frame
	var container := $MinimapContainer
	minimap_size = container.size
	var minimap_cam = get_tree().get_first_node_in_group("MinimapCamera")
	if minimap_cam:
		minimap_cam.minimap_display_size = minimap_size
		minimap_cam._update_zoom()


func _process(_delta: float) -> void:
	## Redraw dots every frame
	dot_layer.queue_redraw()


func _draw_dots() -> void:
	## Called by dot_layer — see MinimapDotLayer below
	pass


## Converts a world position to minimap local position
func world_to_minimap(world_pos: Vector2) -> Vector2:
	if player == null:
		print("Player not found")
		return Vector2.ZERO

	var minimap_cam = get_tree().get_first_node_in_group("MinimapCamera")
	if minimap_cam == null:
		print("Minimap Camera can't be found")
		return Vector2.ZERO
		
	var actual_size: Vector2 = dot_layer.size   # use actual rendered size
	var cam_zoom: Vector2 = minimap_cam.zoom
	var visible_world_size: Vector2 = actual_size / cam_zoom
	var offset: Vector2 = world_pos - player.global_position
	var normalized: Vector2 = offset / visible_world_size
	return (actual_size / 2.0) + normalized * actual_size
