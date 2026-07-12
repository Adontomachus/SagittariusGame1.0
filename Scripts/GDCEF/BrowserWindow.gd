extends CanvasLayer

signal browser_closed

@onready var texture := $Window/TextureRect
@onready var cef := get_tree().get_first_node_in_group("CEF")

## Add this export — assign your forward button in the inspector
@export var forward_button: Button
@export var forward_url: String = ""  ## set this per use case or leave empty

var came_from_boss: bool = false
var browser: GdBrowserView


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false
	if forward_button:
		forward_button.pressed.connect(_on_forward_pressed)


func open(url: String, is_boss_reward: bool = false, next_url: String = "") -> void:
	visible = true
	came_from_boss = is_boss_reward
	forward_url = next_url

	## Show/hide forward button depending on whether a next URL is provided
	if forward_button:
		forward_button.visible = next_url != ""

	var gmanager = get_tree().get_first_node_in_group("GManager")
	if gmanager:
		gmanager._pauseGame()
	if browser == null:
		browser = cef.create_browser(url, texture, {"width": 600, "height": 900})
	else:
		browser.load_url(url)


func navigate_to(url: String) -> void:
	if browser == null:
		return
	browser.load_url(url)


func _on_forward_pressed() -> void:
	if forward_url == "":
		return
	## Close current browser content and open next URL
	navigate_to(forward_url)
	## Clear forward URL so button hides after first use
	forward_url = ""
	if forward_button:
		forward_button.visible = false


func forward_input(event: InputEvent) -> void:
	if browser == null:
		return
	if event is InputEventMouseMotion:
		var pos = texture.get_local_mouse_position()
		browser.set_mouse_moved(int(pos.x), int(pos.y))
	elif event is InputEventMouseButton:
		match event.button_index:
			MOUSE_BUTTON_LEFT:
				if event.pressed: browser.set_mouse_left_down()
				else: browser.set_mouse_left_up()
			MOUSE_BUTTON_RIGHT:
				if event.pressed: browser.set_mouse_right_down()
				else: browser.set_mouse_right_up()
			MOUSE_BUTTON_WHEEL_UP:
				browser.set_mouse_wheel_vertical(1)
			MOUSE_BUTTON_WHEEL_DOWN:
				browser.set_mouse_wheel_vertical(-1)


func _on_pressed() -> void:
	visible = false
	var gmanager = get_tree().get_first_node_in_group("GManager")
	if gmanager:
		gmanager._resumeGame()
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
