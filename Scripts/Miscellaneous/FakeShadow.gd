class_name FakeShadow
extends Node2D

@export var shadow_radius: float = 80.0
@export var shadow_color: Color = Color(0, 0, 0, 0.4)
@export var shadow_squash: float = 0.4  ## flattens the circle into an ellipse
@export_category("Shadow Settings")
@export var shadow_offset: Vector2 = Vector2(0, 8)
@export_range(0.0, 1.0) var shadow_opacity: float = 0.6
var shadow_sprite: Sprite2D

@export var player_ref: PlayerCharacter
@export var neutral_offset: Vector2 = Vector2(0, 30)
@export var facing_offset_strength: float = 10.0  
@export var min_speed_for_movement_priority: float = 10.0


func _process(_delta: float) -> void:
	if player_ref == null:
		return
	_update_facing_offset()

func _ready() -> void:
	z_index = -1
	_create_shadow_texture()
	
func _update_facing_offset() -> void:
	var behind_dir := -_get_priority_direction()
	position = neutral_offset + behind_dir * facing_offset_strength

func _get_priority_direction() -> Vector2:
	var velocity := player_ref.velocity
	if velocity.length() > min_speed_for_movement_priority:
		return velocity.normalized()
	return _get_facing_vector(player_ref.current_facing)

func _get_facing_vector(facing: PlayerCharacter.FacingDirection) -> Vector2:
	match facing:
		PlayerCharacter.FacingDirection.RIGHT:      return Vector2(2, 0)
		PlayerCharacter.FacingDirection.DOWN_RIGHT:  return Vector2(0.7, 0.7)
		PlayerCharacter.FacingDirection.DOWN:        return Vector2(0, 1)
		PlayerCharacter.FacingDirection.DOWN_LEFT:   return Vector2(-0.7, 0.7)
		PlayerCharacter.FacingDirection.LEFT:        return Vector2(-2, 0)
		PlayerCharacter.FacingDirection.UP_LEFT:     return Vector2(-0.7, -0.7)
		PlayerCharacter.FacingDirection.UP:          return Vector2(0, -1)
		PlayerCharacter.FacingDirection.UP_RIGHT:    return Vector2(0.7, -0.7)
	return Vector2.ZERO

## Cache so it's only built once
static var cached_shadow_texture: ImageTexture = null


func _create_shadow_texture() -> void:
	if cached_shadow_texture == null:
		cached_shadow_texture = _generate_texture()

	shadow_sprite = Sprite2D.new()
	shadow_sprite.texture = cached_shadow_texture
	shadow_sprite.modulate = Color(
		shadow_color.r,
		shadow_color.g,
		shadow_color.b,
		shadow_opacity
	)
	shadow_sprite.scale = Vector2(1.0, shadow_squash)

	## Manual per-instance offset
	shadow_sprite.position = shadow_offset

	add_child(shadow_sprite)


func _generate_texture() -> ImageTexture:
	var size := int(shadow_radius * 2)
	var image := Image.create(size, size, false, Image.FORMAT_RGBA8)
	var center := Vector2(size / 2.0, size / 2.0)
	for y in range(size):
		for x in range(size):
			var dist := Vector2(x, y).distance_to(center) / (size / 2.0)
			var alpha := smoothstep(0.0, 1.0, clampf(1.0 - dist, 0.0, 1.0))
			image.set_pixel(x, y, Color(1, 1, 1, alpha))  
	return ImageTexture.create_from_image(image)
