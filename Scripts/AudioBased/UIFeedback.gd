extends CanvasLayer
var tween: Tween
@onready var texture_progress_bar: TextureProgressBar = $UI/PlayerInfo/TextureProgressBar
@onready var wave_notification: Label = $UI/WaveNotification

@onready var player_health_bar: ProgressBar = $UI/PlayerInfo/PlayerHealthBar
@onready var score: Label = $UI/PlayerInfo/Score
@onready var wave_counter: Label = $UI/PlayerInfo/WaveCounter

@export var starting_scale: float =3
@export var tempo: float = 120.0
var pulsePerBeat = 60.0 / tempo

func _ready() -> void:
	score.scale = Vector2(25, 25)
	return

func ui_indicator_pulse() -> void:
	if tween:
		tween.kill()
	tween = create_tween()

	player_health_bar.scale = Vector2(starting_scale, starting_scale)
	tween.tween_property(self, "scale", Vector2(1.0, 1.0), pulsePerBeat / 1.0).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN_OUT)
