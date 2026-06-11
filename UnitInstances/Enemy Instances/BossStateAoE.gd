class_name BossStateAoE
extends EnemyState

@export var next_state: EnemyState

@export_category("AoE Settings")
@export var aoe_count: int = 5           ## how many aoe zones per activation
@export var beats_between_aoe: int = 3   ## beats between each aoe placement
@export var telegraph_duration: float = 1.5  ## seconds telegraph shows before hit
@export var aoe_radius: float = 100.0
@export var aoe_damage: float = 30.0
@export var aoe_offset_range: float = 200.0  ## how far from player aoe can land

var aoe_fired: int = 0
var beats_elapsed: int = 0
var last_beat: float = 0.0

var telegraph_scene := preload("res://Objects/Instances With Collision/BossAOETelegraph.tscn")


func enter() -> void:
	super()
	aoe_fired = 0
	beats_elapsed = 0
	last_beat = beat_sync.beat if beat_sync else 0.0


func process_frame(_delta: float) -> EnemyState:
	if beat_sync == null:
		return null

	var current_beat := beat_sync.beat
	if current_beat > last_beat:
		last_beat = current_beat
		beats_elapsed += 1

		if beats_elapsed >= beats_between_aoe:
			beats_elapsed = 0
			_place_aoe()
			aoe_fired += 1

			if aoe_fired >= aoe_count:
				return next_state

	return null


func _place_aoe() -> void:
	if parent.target == null:
		return

	## Place near player with random offset so it's dodgeable
	var offset := Vector2(
		randf_range(-aoe_offset_range, aoe_offset_range),
		randf_range(-aoe_offset_range, aoe_offset_range)
	)
	var target_pos := parent.target.global_position + offset

	## Show telegraph then deal damage
	_telegraph_and_hit.call_deferred(target_pos)


func _telegraph_and_hit(target_pos: Vector2) -> void:
	## Spawn telegraph
	var telegraph = telegraph_scene.instantiate()
	get_tree().current_scene.add_child(telegraph)
	telegraph.global_position = target_pos
	telegraph.show_warning(telegraph_duration)

	## Wait for telegraph duration
	await get_tree().create_timer(telegraph_duration).timeout

	## Check if telegraph is still valid
	if not is_instance_valid(telegraph):
		return

	telegraph.queue_free()

	## Check if player is in range — single damage instance
	if parent.target == null:
		return

	var dist := parent.target.global_position.distance_to(target_pos)
	if dist <= aoe_radius:
		parent.target.modify_current_player_health(-int(aoe_damage))

		## Visual feedback
		var camera := get_tree().get_first_node_in_group("CameraControl")
		if camera:
			camera.add_trauma(0.5)

	## Show explosion visual
	_spawn_explosion(target_pos)


func _spawn_explosion(pos: Vector2) -> void:
	## Reuse your existing AoE hit effect
	var effect := preload("res://Objects/Instances With Collision/GrenadeExplosion.tscn").instantiate()
	effect.global_position = pos
	get_tree().current_scene.add_child(effect)


func exit() -> void:
	pass
