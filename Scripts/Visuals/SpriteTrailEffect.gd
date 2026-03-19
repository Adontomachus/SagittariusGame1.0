extends Sprite2D

@onready var bullet_sprite: Sprite2D = $"."
# @onready var splash_bullet: ProjectileCommon = $".."

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if (get_tree().get_frame() % 8) == 0:
		#var sprite_trail: Sprite2D = bullet_sprite.duplicate()
		#get_tree().root.add_child(sprite_trail)
		#sprite_trail.global_position = self.global_position
		#sprite_trail.global_rotation = self.global_rotation
		return
	pass
