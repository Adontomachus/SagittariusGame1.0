class_name ShoutLob
extends Node2D

@export var arc_height: float = 60.0
@export var damage: float = 20.0

var telegraph_scene := preload("res://Objects/Instances With Collision/ShoutTelegraph.tscn")
var aoe_scene := preload("res://Objects/Instances With Collision/ShoutAoE.tscn")

var start_position: Vector2
var target_position: Vector2
var travel_time: float = 0.0
# Multipler on how long shout will arrive
var travel_time_multiplier: float= 3
var elapsed: float = 0.0
var is_travelling: bool = false

@onready var sprite: Sprite2D = $Sprite2D

var telegraph: Node2D


func launch(from: Vector2, to: Vector2, beat_sync: BeatSync_Script) -> void:
	start_position = from
	target_position = to
	## Travel time = 3 full beats
	travel_time = beat_sync.pulsePerBeat * travel_time_multiplier
	elapsed = 0.0
	is_travelling = true
	global_position = from

	## Spawn telegraph at target immediately
	telegraph = telegraph_scene.instantiate()
	get_tree().get_root().call_deferred("add_child", telegraph)
	await get_tree().process_frame
	telegraph.global_position = target_position
	telegraph.show_warning(travel_time)


func _physics_process(delta: float) -> void:
	if not is_travelling:
		return

	elapsed += delta
	var t := clampf(elapsed / travel_time, 0.0, 1.0)

	var flat_position := start_position.lerp(target_position, t)
	var arc_offset := -arc_height * 4.0 * t * (t - 1.0)
	global_position = flat_position + Vector2(0, -arc_offset)

	## Scale to fake depth
	var scale_value := lerpf(0.4, 1.0, t)
	sprite.scale = Vector2(scale_value, scale_value)
	sprite.rotation += delta * 4.0

	if t >= 1.0:
		is_travelling = false
		_land()


func _land() -> void:
	var land_pos := global_position

	## Remove telegraph
	if telegraph and is_instance_valid(telegraph):
		telegraph.queue_free()

	## Spawn AoE
	var aoe = aoe_scene.instantiate()
	get_tree().get_root().call_deferred("add_child", aoe)
	await get_tree().process_frame
	aoe.global_position = land_pos
	aoe.damage = damage

	queue_free()
