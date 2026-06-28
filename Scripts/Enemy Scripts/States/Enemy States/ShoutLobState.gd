class_name ShoutLobState
extends EnemyState

@export var idle_state: EnemyState
# How many beats before they can fire again
@export var beats_between_shots: int = 12
# Range how far the fire can go
@export var aim_randomness: float = 300
# Chance of fire per beat if they can already
@export_range(0.0, 1.0) var shoot_chance_per_beat: float = 0.25
# Range on how far can the unit shoot its lobbed attacks
@export var attack_range: float = 500

var beats_waited: int = 0
var last_beat: float = 0
var world_parent: Node2D


func enter() -> void:
	super()
	beats_waited = 0
	if beat_sync:
		last_beat = beat_sync.beat
	world_parent = get_tree().current_scene.get_node_or_null(
		"GameLevelNode/Stage1/EnemyNavRegion/Map Objects/World"
	)

# Wait for beats_between_shots before shoot
func process_frame(_delta: float) -> EnemyState:
	# Checks the range between unit and player
	var target_distance = parent.global_position.distance_to(parent.target.global_position)
	
	if beat_sync == null:
		print("beat_sync not connected")
		return null

	var current_beat: float = beat_sync.beat
	if current_beat > last_beat:
		last_beat = current_beat
		beats_waited += 1
		# Makes timing of shot more random
		if beats_waited >= beats_between_shots:
			if randf() < shoot_chance_per_beat:
				beats_waited = 0
				if target_distance < attack_range:
					_fire_shout()

	return null


func _fire_shout() -> void:
	if parent.target == null:
		print("Can't find suitable target")
		return

	## Get a random point near the player circularly
	var random_angle := randf() * TAU
	var random_distance := randf() * aim_randomness
	var random_offset := Vector2(cos(random_angle), sin(random_angle)) * random_distance
	var target_pos := parent.target.global_position + random_offset

	## Spawn the lob projectile
	print("stationary trying to shout")
	var lob_scene := preload("res://Objects/Instances With Collision/ShoutLob.tscn")
	var lob = lob_scene.instantiate()
	world_parent.call_deferred("add_child", lob)
	await parent.get_tree().process_frame
	lob.launch(parent.global_position, target_pos, beat_sync)
	lob.damage = parent.attackPower
