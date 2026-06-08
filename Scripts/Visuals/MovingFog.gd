class_name MovingFog
extends Node2D

@export_category("Fog Settings")
@export var fog_color: Color = Color(0.05, 0.05, 0.1, 0.35)
@export var fog_layer_count: int = 4
@export var fog_texture: Texture2D
@export var fog_scale_min: float = 8.0
@export var fog_scale_max: float = 14.0
@export var speed_min: float = 8.0
@export var speed_max: float = 22.0
## How far fog layers drift before wrapping
@export var level_size: Vector2 = Vector2(2000, 2000)

var fog_layers: Array = []


func _ready() -> void:
	_spawn_fog_layers()


func _spawn_fog_layers() -> void:
	for i in range(fog_layer_count):
		var sprite := Sprite2D.new()
		sprite.texture = fog_texture
		sprite.modulate = fog_color

		var scale_value := randf_range(fog_scale_min, fog_scale_max)
		sprite.scale = Vector2(scale_value, scale_value)

		## Random starting position within the level
		sprite.position = Vector2(
			randf_range(0, level_size.x),
			randf_range(0, level_size.y)
		)

		var layer_data := {
			"sprite": sprite,
			"velocity": Vector2(
				randf_range(-speed_max, speed_max),
				randf_range(-speed_max, speed_max)
			).normalized() * randf_range(speed_min, speed_max),
			"rotation_speed": randf_range(-0.02, 0.02)
		}

		fog_layers.append(layer_data)
		add_child(sprite)


func _process(delta: float) -> void:
	for layer in fog_layers:
		var sprite: Sprite2D = layer.sprite
		sprite.position += layer.velocity * delta
		sprite.rotation += layer.rotation_speed * delta

		## Wrap around level bounds
		if sprite.position.x > level_size.x:
			sprite.position.x = 0
		elif sprite.position.x < 0:
			sprite.position.x = level_size.x
		if sprite.position.y > level_size.y:
			sprite.position.y = 0
		elif sprite.position.y < 0:
			sprite.position.y = level_size.y
