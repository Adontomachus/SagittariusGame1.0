class_name HUDClass
extends CanvasLayer
var tween: Tween

@onready var wave_notification: Label = $UI/WaveNotification

# Color & Glow Effects
@onready var updated_player_health_bar: TextureProgressBar = $UI/PlayerInfo/UpdatedPlayerHealthBar
@onready var updated_boss_health_bar: TextureProgressBar = $UI/UpdatedBossHealthBar


@onready var score: Label = $UI/PlayerInfo/Score
@onready var wave_counter: Label = $UI/PlayerInfo/WaveCounter
@onready var combo_counter: Label = $UI/PlayerInfo/ComboCounter
@export var starting_scale: float =  3
@export var tempo: float = 120.0
var pulsePerBeat = 60.0 / tempo

#TESTING PURPOSES
var timeToChangeColor = 0.5
var glow_strength: float = 1
var current_glow_strength: float

func _ready() -> void:

	return

func _process(delta: float):
	timeToChangeColor -= 1 * delta
	#print (GlobalBeatSync.lastBeat)
	if current_glow_strength < glow_strength: current_glow_strength = glow_strength
	else: current_glow_strength -= 1 * delta

		
	change_color()
	if timeToChangeColor < 0:
		timeToChangeColor = 0.5
		current_glow_strength = 1.15
		return
	pass

func ui_indicator_pulse() -> void:
	if tween:
		tween.kill()
	tween = create_tween()

	updated_player_health_bar.scale = Vector2(starting_scale, starting_scale)
	tween.tween_property(self, "scale", Vector2(1.0, 1.0), pulsePerBeat / 1.0).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN_OUT)


	

func change_color() -> void:
	updated_boss_health_bar.self_modulate = Color(current_glow_strength,current_glow_strength,current_glow_strength,current_glow_strength)
	updated_player_health_bar.self_modulate = Color(current_glow_strength,current_glow_strength,current_glow_strength,current_glow_strength)
	#pass # Replace with function body.
