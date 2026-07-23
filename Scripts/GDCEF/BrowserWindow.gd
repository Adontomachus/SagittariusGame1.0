extends CanvasLayer

signal browser_closed

@onready var texture := $Window/TextureRect
@onready var cef := get_tree().get_first_node_in_group("CEF")
@onready var loading_overlay: Control = $Window/LoadingOverlay

@export var close_button: TextureButton

var came_from_boss: bool = false
var browser: GdBrowserView

## URL queue — next URL to load when close is pressed
var url_queue: Array[String] = []


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false
	if close_button:
		close_button.pressed.connect(_on_close_pressed)
		close_button.visible = true

var loading_visible := true
@onready var loading_icon := $Window/LoadingOverlay/ColorRect/Sprite2D
var last_url := ""

func _process(delta):
	if browser == null:
		return

	var current_url := browser.get_url()

	if current_url != last_url:
		last_url = current_url
		loading_visible = true
		loading_overlay.show()
		loading_overlay.modulate.a = 1.0

	if browser.is_loaded() and loading_visible:
		loading_visible = false
		var tween = create_tween()
		tween.tween_property(loading_overlay, "modulate:a", 0.0, 0.25)
		await tween.finished
		loading_overlay.hide()
		loading_overlay.modulate.a = 1.0

	elif !browser.is_loaded() and !loading_visible:
		loading_visible = true
		loading_overlay.show()

	if loading_overlay.visible:
		loading_icon.rotation += delta * TAU
		var s = 1.0 + sin(Time.get_ticks_msec() * 0.005) * 0.08
		loading_icon.scale = Vector2.ONE * s


func open(url: String, is_boss_reward: bool = false, url_list: Array[String] = []) -> void:
	visible = true
	came_from_boss = is_boss_reward
	loading_overlay.show()

	## Build queue: first URL loads immediately, remaining URLs queued for next close press
	url_queue.clear()
	if url_list.is_empty():
		url_queue.append(url)
	else:
		url_queue = url_list.duplicate()

	var gmanager := get_tree().get_first_node_in_group("GManager")
	if gmanager:
		gmanager._pauseGame()

	## Load the first URL immediately
	_load_next_url()


func _load_next_url() -> void:
	if url_queue.is_empty():
		_close_browser_and_end_level()
		return

	var next_url := url_queue[0]
	_show_loading()

	if browser == null:
		browser = cef.create_browser(next_url, texture, {"width": 600, "height": 900})
		last_url = browser.get_url()
	else:
		browser.load_url(next_url)


func _show_loading() -> void:
	loading_visible = true
	loading_overlay.modulate.a = 1.0
	loading_overlay.show()


func _on_close_pressed() -> void:
	## Pop the current URL from queue and load next
	if not url_queue.is_empty():
		url_queue.remove_at(0)

	if url_queue.is_empty():
		## No more URLs — close browser and end level
		_close_browser_and_end_level()
	else:
		## More URLs remain — load next one
		_load_next_url()


func _close_browser_and_end_level() -> void:
	_close_browser()

	var gmanager := get_tree().get_first_node_in_group("GManager")
	if gmanager:
		gmanager._resumeGame()

	_trigger_level_end()
	browser_closed.emit()


func _close_browser() -> void:
	if browser != null:
		browser.close()
		browser = null
	visible = false
	url_queue.clear()


func _trigger_level_end() -> void:
	var cinematics_handler := get_tree().get_first_node_in_group("SceneGroup")
	if cinematics_handler:
		cinematics_handler.show_victory()
	get_tree().paused = true
	LevelManager.currentLevel += 1
	LevelManager._unlock_level(LevelManager.currentLevel)


func forward_input(event: InputEvent) -> void:
	if browser == null:
		return
	if event is InputEventMouseMotion:
		var pos: Vector2 = texture.get_local_mouse_position()
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
