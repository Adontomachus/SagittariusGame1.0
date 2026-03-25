class_name CompanionGroup
extends CharacterBody2D
@export_group("State Machine")
@export var state_machine: CompanionStateMachine

@export_group("Other Variables")
@export var companion_sprite: Sprite2D
@export var pathfinding: NavigationAgent2D

@export_group("Companion Stats")
@export var attack_power: float
@export var move_speed: float

@export_group("Player Master and Nearest Target")
var player_target: CharacterBody2D
@export var player_radius: float
var enemy_target: CharacterBody2D
# @export var time_to_relocate: float = 5


	
# Targets for location points
@onready var target_looker: Marker2D = $NearestEnemyTarget
@onready var master_target_location: Marker2D = $PlayerTarget

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	state_machine.init(self)
	player_target = get_tree().get_first_node_in_group("PlayerObject")
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	state_machine.process_frame(delta)
	pass

func move_companion(delta: float) -> void:
	var targetLocation = pathfinding.get_next_path_position()
	var new_velocity = global_position.direction_to(targetLocation) * move_speed
	
	velocity = new_velocity
	
	if (pathfinding.avoidance_enabled):
		pathfinding.set_velocity(new_velocity)
		
	move_and_slide()

func _physics_process(delta: float) -> void:
	#pathfinding.target_position = player_target.global_position
	target_looker.look_at(player_target.global_position)
	companion_sprite.look_at(player_target.global_position)
	state_machine.process_physics(delta)


	pass
