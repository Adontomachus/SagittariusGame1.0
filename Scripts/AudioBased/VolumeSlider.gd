extends HSlider

@export var audio_bus_name: String
var audio_bus_id

func _ready():
	audio_bus_id = AudioServer.get_bus_index(audio_bus_name)
	var volume_settings = SaveSettings._load_volume_settings()
	
	if volume_settings.has(audio_bus_name):
		var saved_volume = volume_settings[audio_bus_name]
		value = saved_volume
		AudioServer.set_bus_volume_db(audio_bus_id, linear_to_db(saved_volume))
	
	# Fallback
	else:
		value = db_to_linear(AudioServer.get_bus_volume_db(audio_bus_id))

func _on_value_changed(value: float) -> void:
	var db = linear_to_db(value)
	AudioServer.set_bus_volume_db(audio_bus_id, db)

func _get_volume() -> float:
	return db_to_linear(AudioServer.get_bus_volume_db(audio_bus_id))
