extends CanvasLayer

signal browser_closed

@onready var texture := $Window/TextureRect
@onready var cef := get_tree().get_first_node_in_group("CEF")
@onready var loading_overlay: Control = $Window/LoadingOverlay

@export var forward_button: Button
@export var back_button: Button
@export var close_button: Button

var came_from_boss: bool = false
var browser: GdBrowserView

## URL history for back/forward navigation
var url_history: Array[String] = []
var current_url_index: int = -1


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false
	if forward_button:
		forward_button.pressed.connect(_on_forward_pressed)
		forward_button.visible = false
	if back_button:
		back_button.pressed.connect(_on_back_pressed)
		back_button.visible = false
	if close_button:
		close_button.pressed.connect(_on_pressed)
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

	## Build history from url_list — first entry is current, rest are forward
	url_history.clear()
	current_url_index = 0

	if url_list.is_empty():
		url_history.append(url)
	else:
		url_history = url_list.duplicate()

	var gmanager := get_tree().get_first_node_in_group("GManager")
	if gmanager:
		gmanager._pauseGame()

	if browser == null:
		browser = cef.create_browser(url_history[0], texture, {"width": 600, "height": 900})
		last_url = browser.get_url()
	else:
		browser.load_url(url_history[0])

	_update_nav_buttons()

func _show_loading() -> void:
	loading_visible = true
	loading_overlay.modulate.a = 1.0
	loading_overlay.show()

func _navigate_to_index(index: int) -> void:
	if index < 0 or index >= url_history.size():
		return
	current_url_index = index
	_show_loading()
	browser.load_url(url_history[current_url_index])
	_update_nav_buttons()


func _update_nav_buttons() -> void:
	var is_last := current_url_index >= url_history.size() - 1

	if back_button:
		back_button.visible = false
		#back_button.visible = current_url_index > 0

	if forward_button:
		forward_button.visible = false
		#forward_button.visible = not is_last

	if close_button:
		close_button.visible = true
		#close_button.visible = is_last


func _on_back_pressed() -> void:
	_navigate_to_index(current_url_index - 1)


func _on_forward_pressed() -> void:
	_navigate_to_index(current_url_index + 1)


func forward_input(event: InputEvent) -> void:
	if browser == null:
		return
	if event is InputEventMouseMotion:
		var pos : Vector2 = texture.get_local_mouse_position()
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
	url_history.clear()
	current_url_index = -1
	if back_button:
		back_button.visible = false
	if forward_button:
		forward_button.visible = false


func _trigger_level_end() -> void:
	var cinematics_handler := get_tree().get_first_node_in_group("SceneGroup")
	if cinematics_handler:
		cinematics_handler.show_victory()
	get_tree().paused = true
	LevelManager.currentLevel += 1
	LevelManager._unlock_level(LevelManager.currentLevel)
