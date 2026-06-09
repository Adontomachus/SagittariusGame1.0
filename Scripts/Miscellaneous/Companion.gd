class_name CompanionGroup
extends CharacterBody2D

#region Variables with export groups
@export_group("State Machine")
@export var state_machine: CompanionStateMachine

@export_group("Other Variables")
@export var companion_sprite: Sprite2D
@export var pathfinding: NavigationAgent2D

@export_group("Companion Stats")
@export var move_speed: float

# These are the main destination points for the companion to follow
@export_group("Player Master")
var player_target: CharacterBody2D
@export var player_radius: float
# dvar enemy_target: CharacterBody2D
#endregion
# @export var time_to_relocate: float = 5

# Targets for location points
@onready var target_looker: Marker2D = $NearestEnemyTarget
@onready var master_target_location: Marker2D = $PlayerTarget

# @onready var nearest_enemy_target: Marker2D = $NearestEnemyTarget

## Marker sprite where it positions itself to the companion's targeted enemy
@onready var enemy_target_marker: Sprite2D = $EnemyTargetMarker

## Variables for companion attack statistics
@export_group("Attacking Stats")
@export var dash_speed: float = 750
@export var companion_damage: float = 30
@export var dash_duration: float = 0.5
var is_dashing: bool = false
## Damage numbers
var damageNumber := preload("res://Objects/UI Elements/DamageNumbers.tscn")
## For scaling hitbox
@export var companion_hitbox: CollisionShape2D
var nearest_enemy: CharacterBody2D = null

## Base stats stored for level scaling
var base_move_speed: float
var base_dash_speed: float
var base_companion_damage: float
var base_hitbox_radius: float
var current_level: int = 0

@export var aggressiveness : float = 1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	state_machine.init(self)
	player_target = get_tree().get_first_node_in_group("PlayerObject")
	## Store base stats for scaling
	base_move_speed = move_speed
	base_dash_speed = dash_speed
	base_companion_damage = companion_damage
	if companion_hitbox and companion_hitbox.shape is CircleShape2D:
		base_hitbox_radius = companion_hitbox.shape.radius

	## Start hidden and disabled until unlocked
	visible = false
	process_mode = Node.PROCESS_MODE_DISABLED

func level_up(value: float) -> void:
	current_level += 1
	var multiplier := 1.0 + (value / 100.0)

	## Scale all stats
	move_speed *= multiplier
	dash_speed *= multiplier
	companion_damage *= multiplier
	aggressiveness = clampf(aggressiveness + 0.2, 1.0, 2.5)

	## Scale hitbox
	if companion_hitbox and companion_hitbox.shape is CircleShape2D:
		companion_hitbox.shape.radius *= multiplier

	print("Companion leveled up to: ", current_level,
		  " | damage: ", companion_damage,
		  " | speed: ", move_speed,
		  " | aggressiveness: ", aggressiveness)


func reset_stats() -> void:
	## Call on scene reset to restore base values
	current_level = 0
	move_speed = base_move_speed
	dash_speed = base_dash_speed
	companion_damage = base_companion_damage
	aggressiveness = 1.0
	if companion_hitbox and companion_hitbox.shape is CircleShape2D:
		companion_hitbox.shape.radius = base_hitbox_radius
	visible = false
	process_mode = Node.PROCESS_MODE_DISABLED


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:

	nearest_enemy = _find_closest_enemy()
	if nearest_enemy:
		enemy_target_marker.global_position = nearest_enemy.global_position
		enemy_target_marker.visible = true
	else:
		enemy_target_marker.visible = false
	# print("Nearest: ", nearest_enemy)saawdwdaasaas
	state_machine.process_frame(delta)
	pass

#region Pathfinding functions
## Function for follow movement
func move_companion(delta: float) -> void:
	var targetLocation = pathfinding.get_next_path_position()
	var new_velocity = global_position.direction_to(targetLocation) * move_speed
	
	velocity = new_velocity
	
	if (pathfinding.avoidance_enabled):
		pathfinding.set_velocity(new_velocity)
		
	move_and_slide()

## Function for dashing towards the marked enemy target
func _rush_towards_target(delta: float) -> void:
	var targetLocation = pathfinding.get_next_path_position()
	var new_velocity = global_position.direction_to(targetLocation) * dash_speed
	
	velocity = new_velocity
	
	if (pathfinding.avoidance_enabled):
		pathfinding.set_velocity(new_velocity)
		
	move_and_slide()
#endregion

func _physics_process(delta: float) -> void:
	
	# enemy_target_marker.position = nearest_enemy.global_position
	
	target_looker.look_at(player_target.global_position)
	master_target_location.look_at(player_target.global_position)
	companion_sprite.look_at(player_target.global_position)
	state_machine.process_physics(delta)
	
## Function for finding the nearest enemy target
func _find_closest_enemy() -> Object:
	var enemy_target = get_tree().get_nodes_in_group("GeneralEnemyInstance")
	nearest_enemy = null
	var minimum_distance = INF
	## Agressiveness increases range for now
	var max_range := 800.0 * aggressiveness
	for enemy in enemy_target:
		var target_distance = global_position.distance_squared_to(enemy.global_position)
		if target_distance < minimum_distance and target_distance < max_range * max_range:
			minimum_distance = target_distance
			nearest_enemy = enemy
	return nearest_enemy

## Function for upgrading companion damage when the player character levels up
func _on_player_companion_upgrade() -> void:
	companion_damage = companion_damage * 1.07
	pass
	
