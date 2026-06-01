extends Node

var config = ConfigFile.new()
const SETTINGS_FILE_PATH = "user://settings.ini"

func _ready():
	# Default settings if config file does not exist
	if !FileAccess.file_exists(SETTINGS_FILE_PATH):
		print("Save File Does Not Exist")
		config.set_value("volume", "Master", 0.5)
		config.set_value("volume", "Music", 0.5)
		config.set_value("volume", "SFX", 0.5)
		
		config.set_value("video", "fullscreen", true)
		
		config.set_value("gameplay", "difficulty", 1)
		
		config.save(SETTINGS_FILE_PATH)
	else:
		config.load(SETTINGS_FILE_PATH)

func _save_video_settings(key: String, value):
	config.set_value("video", key, value)
	config.save(SETTINGS_FILE_PATH)

func _load_video_settings():
	var videoSettings = {}
	for key in config.get_section_keys("video"):
		videoSettings[key] = config.get_value("video", key)
	return videoSettings

func _save_volume_settings(key: String, value):
	config.set_value("volume", key, value)
	config.save(SETTINGS_FILE_PATH)

func _load_volume_settings():
	var volumeSettings = {}
	for key in config.get_section_keys("volume"):
		volumeSettings[key] = config.get_value("volume", key)
	return volumeSettings

func _save_difficulty_settings(key: String, value):
	config.set_value("gameplay", key, value)
	config.save(SETTINGS_FILE_PATH)

func _load_difficulty_settings():
	var difficultySettings = config.get_value("gameplay", "difficulty")
	print(difficultySettings)
	return difficultySettings
