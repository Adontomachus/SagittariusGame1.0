extends Sprite2D

signal glow_on_beat()



func _ready() -> void:
	
#	glow_on_beat.emit(self.name)
	return


func _on_glow_on_beat() -> void:
	self_modulate = Color(1.0, 1.0, 0.0, 2.0)
	pass # Replace with function body.
