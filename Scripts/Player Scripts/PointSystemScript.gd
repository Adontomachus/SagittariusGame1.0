class_name PointSystems
extends Node

var playerScore: int
var playerHighScore: int
var accuracy: float
var total_accuracy: float
var raw_accuracy: float
var total_damage_dealt: float
var player_levels: int
var player_charged_shot: bool

## Sets the glow animations for charged shot glow feedback
@export var glow_animations: AnimationPlayer
# @onready var glow_animation_player: AnimationPlayer = $"../../InterfaceElements/NewHUD/GlowAnimationPlayer"

func _process(_delta):
	if player_charged_shot:
		if GlobalBeatSync.lastBeat < GlobalBeatSync.beat:
			#glow_animations.play("GlowPulse")
			pass
	else:
		pass
