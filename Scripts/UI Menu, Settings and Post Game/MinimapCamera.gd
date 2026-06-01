class_name MinimapCamera
extends Camera2D

## This implementation follows the player, the minimap shows 2.5 times larger space than
## what can be seen
@export var zoom_multiplier: float = 5
@export var minimap_display_size: Vector2 = Vector2(200, 200)
@export var level_origin: Vector2 = Vector2(0, 0)
@export var level_size: Vector2 = Vector2(3000, 3000)

var player: PlayerCharacter
var main_camera: Camera2D



func _ready() -> void:
	enabled = true
	player = get_tree().get_first_node_in_group("PlayerObject")
	main_camera = get_tree().get_first_node_in_group("CameraControl")
	_update_zoom()


func _process(_delta: float) -> void:
	if not player:
		return
	if player:
		global_position = player.global_position

func _update_zoom() -> void:
	if main_camera == null:
		## Fallback if main camera not found
		zoom = Vector2(0.3, 0.3)
		return

	## Match main camera zoom then divide by multiplier to zoom out further
	var base_zoom := main_camera.zoom
	zoom = base_zoom / zoom_multiplier
