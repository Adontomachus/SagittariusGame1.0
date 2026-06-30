extends TextureProgressBar

@export var shake_duration: float = 0.1
@export var shake_strength: float = 5
@export var shake_frequency: float = 5

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _health_interface_shake() -> void:
	var shake_tween = create_tween()
	var steps = int(shake_duration * shake_frequency)
	var step_duration = shake_duration / steps
	
	var original_position = position
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	
	# Loop for steps
	for	y in range(steps):
		var current_intensity = shake_strength * (1.0 - (float(y)/ steps))
		var random_offset = Vector2(
			rng.randf_range(-current_intensity, current_intensity),
			rng.randf_range(-current_intensity, current_intensity)
		)
		
		shake_tween.tween_property(self, "position", original_position + random_offset, step_duration)
		shake_tween.set_trans(Tween.TRANS_SINE)
		shake_tween.set_ease(Tween.EASE_OUT)
		
		shake_tween.tween_property(self, "position", original_position, 0.1)
