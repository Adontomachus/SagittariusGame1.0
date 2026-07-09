extends CanvasLayer
signal browser_closed 
@onready var texture := $Window/TextureRect
@onready var cef := get_tree().get_first_node_in_group("CEF")
var came_from_boss: bool = false

var browser: GdBrowserView

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false

func open(url: String, is_boss_reward: bool = false) -> void:
	visible = true
	came_from_boss = is_boss_reward
	var gmanager = get_tree().get_first_node_in_group("GManager")
	if gmanager:
		gmanager._pauseGame()
	if browser == null:
		browser = cef.create_browser(url, texture, {"width": 900, "height": 600})
	else:
		browser.load_url(url)

func forward_input(event):
	if browser == null:
		return

	if event is InputEventMouseMotion:
		var pos = texture.get_local_mouse_position()

		browser.set_mouse_moved(
			int(pos.x),
			int(pos.y)
		)

	elif event is InputEventMouseButton:
		match event.button_index:
			MOUSE_BUTTON_LEFT:
				if event.pressed:
					browser.set_mouse_left_down()
				else:
					browser.set_mouse_left_up()

			MOUSE_BUTTON_RIGHT:
				if event.pressed:
					browser.set_mouse_right_down()
				else:
					browser.set_mouse_right_up()

			MOUSE_BUTTON_WHEEL_UP:
				browser.set_mouse_wheel_vertical(1)

			MOUSE_BUTTON_WHEEL_DOWN:
				browser.set_mouse_wheel_vertical(-1)

func _on_pressed() -> void:
	## Close button pressed
	visible = false
	var gmanager = get_tree().get_first_node_in_group("GManager")
	if gmanager:
		gmanager._resumeGame()

	## If this was opened after boss death, now end the level
	if came_from_boss:
		_trigger_level_end()

	browser_closed.emit()


func _trigger_level_end() -> void:
	var cinematics_handler = get_tree().get_first_node_in_group("SceneGroup")
	if cinematics_handler:
		cinematics_handler.game_is_won = true

	get_tree().paused = true

	LevelManager.currentLevel += 1
	LevelManager._unlock_level(LevelManager.currentLevel)
