extends Node
class_name LevelSceneHandler

var game_is_over: bool = false
var game_is_won: bool = false
var can_play_animation: bool = true
#@onready var cutscene_background: ColorRect = $"../../InterfaceElements/NewHUD/UI/CutsceneUI/CutsceneBackground"
@export var game_over_animations: AnimationPlayer
@export var game_win_animations: AnimationPlayer
@onready var win_screen: Control = $"../../InterfaceElements/NewHUD/UI/CutsceneUI/GameOverNode/WinScreen"
@onready var lose_screen: Control = $"../../InterfaceElements/NewHUD/UI/CutsceneUI/GameOverNode/LoseScreen"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if game_is_over == true:
		lose_screen.visible = true
		if can_play_animation:
			can_play_animation = false
			game_over_animations.play("GameOver")
		#cutscene_background.visible = true
	if game_is_won == true:
		win_screen.visible = true
		if can_play_animation:
			can_play_animation = false
			game_win_animations.play("GameVictory")
	pass
