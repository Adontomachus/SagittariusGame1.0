extends Button

var level: int = 1
var isUnlocked: bool = false

func _ready() -> void:
	level = get_index() + 1
	text = str(level)
	isUnlocked = level <= LevelManager.levelUnlocked
	
	#makes button opaque if level is not unlocked yet
	modulate.a = 1.0 if isUnlocked else 0.5

# Allows to change level based on if the level pressed is unlocked already
func _pressed() -> void:
	if isUnlocked:
		print("I am unlocked and trying to access Level ", LevelManager.currentLevel)
		LevelManager.currentLevel = level
		LevelManager._load_level(level)
