class_name CompanionGroup
extends Node

@export_group("Companion Stats")
@export var attack_power: float
@export var move_speed: float

@export_group("Player Master")
@export var player_target: CharacterBody2D
@export var time_to_relocate: float = 5

@export_group("State Machine")
@export var state_machine: CompanionStateMachine
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
