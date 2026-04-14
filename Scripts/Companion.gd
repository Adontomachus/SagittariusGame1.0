class_name CompanionGroup
extends CharacterBody2D

#region Variables with export groups
@export_group("State Machine")
@export var state_machine: CompanionStateMachine

@export_group("Other Variables")
@export var companion_sprite: Sprite2D
@export var pathfinding: NavigationAgent2D

@export_group("Companion Stats")
@export var attack_power: float
@export var move_speed: float

# These are the main destination points for the companion to follow
@export_group("Player Master and Nearest Target")
var player_target: CharacterBody2D
@export var player_radius: float
var enemy_target: CharacterBody2D
#endregion
# @export var time_to_relocate: float = 5

# Targets for location points
@onready var target_looker: Marker2D = $NearestEnemyTarget
@onready var master_target_location: Marker2D = $PlayerTarget

@onready var nearest_enemy_target: Marker2D = $NearestEnemyTarget

## Marker sprite where it positions itself to the companion's targeted enemy
@onready var enemy_target_marker: Sprite2D = $EnemyTargetMarker


var nearest_enemy = null



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	state_machine.init(self)
	player_target = get_tree().get_first_node_in_group("PlayerObject")
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	nearest_enemy = _find_closest_enemy()
	enemy_target_marker.global_position = nearest_enemy.global_position
	print("Nearest: ", nearest_enemy)
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
	# enemy_target_marker.position = nearest_enemy.global_position
	
	target_looker.look_at(player_target.global_position)
	master_target_location.look_at(player_target.global_position)
	companion_sprite.look_at(player_target.global_position)
	state_machine.process_physics(delta)
	
## Function for finding the nearest enemy target
func _find_closest_enemy() -> Object:
	var enemy_target = get_tree().get_nodes_in_group("GeneralEnemyInstance")
	var minimum_distance = INF
	for enemy in enemy_target:
		var target_distance = global_position.distance_squared_to(enemy.global_position)
		# print("Distance: ", dstarget_distance)
		if target_distance < minimum_distance:
			minimum_distance = target_distance
			nearest_enemy = enemy
	return nearest_enemy
