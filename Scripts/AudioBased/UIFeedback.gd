extends CanvasLayer
var tween: Tween

@onready var wave_notification: Label = $UI/WaveNotification

# Color & Glow Effects
@onready var updated_player_health_bar: TextureProgressBar = $UI/PlayerInfo/UpdatedPlayerHealthBar
signal change_color(color)


@onready var score: Label = $UI/PlayerInfo/Score
@onready var wave_counter: Label = $UI/PlayerInfo/WaveCounter
@onready var combo_counter: Label = $UI/PlayerInfo/ComboCounter

@export var starting_scale: float =  3
@export var tempo: float = 120.0
var pulsePerBeat = 60.0 / tempo

#TESTING PURPOSES
var timeToChangeColor = 3
var toChange: bool

func _ready() -> void:
	toChange = true
	change_color.connect(_on_change_color)
	#change_color.emit(Color.CRIMSON)
	#change_color.connect(_on_changed_color)
	return

func _process(delta: float) -> void:
	timeToChangeColor -= 1 * delta
	if toChange && timeToChangeColor < 0:
		toChange = false
		change_color.emit(Color.DARK_GRAY)
		return
	

func ui_indicator_pulse() -> void:
	if tween:
		tween.kill()
	tween = create_tween()

	#updated_player_health_bar.scale = Vector2(starting_scale, starting_scale)
	tween.tween_property(self, "scale", Vector2(1.0, 1.0), pulsePerBeat / 1.0).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN_OUT)


	

func _on_change_color(color: Variant) -> void:
	var tweenBeat = create_tween()
	tweenBeat.tween_property(updated_player_health_bar, "modulate", color, 5)
	updated_player_health_bar.self_modulate = color
	tweenBeat.set_trans(Tween.TRANS_SINE)
	pass # Replace with function body.
