extends CanvasLayer

@onready var texture := $Window/TextureRect
@onready var cef := get_tree().get_first_node_in_group("CEF")

var browser: GdBrowserView

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false

func open(url:String):
	visible = true

	var gmanager = get_tree().get_first_node_in_group("GManager")
	if gmanager:
		gmanager._pauseGame()

		if browser == null:
			browser = cef.create_browser(
			url,
			texture,
			{
				"width": 900,
				"height": 600
			}
			)
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

func _on_pressed():
	var gmanager = get_tree().get_first_node_in_group("GManager")
	if gmanager:
		gmanager._resumeGame()
	visible = false
