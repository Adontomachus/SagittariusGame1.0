class_name ShoutAoE
extends Area2D

@onready var land_sound: AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var sprite: Sprite2D = $Sprite2D
@onready var collision: CollisionShape2D = $CollisionShape2D
var linger_tween: Tween

@export var damage: float = 10.0
@export var radius: float = 200

## How many beats the AoE zone lingers on the ground
@export var linger_beats: int = 7

## DOT and slow settings
@export var dot_damage_per_beat: float = 5
@export var dot_duration_beats: int = 13
@export var slow_multiplier: float = 0.8
@export var slow_duration_beats: int = 13

var beat_sync: BeatSync_Script
var beats_elapsed: int = 0
var last_beat: float = 0.0
var affected_players: Array = []  ## track who is already slowed/dotted


func _ready() -> void:
	beat_sync = get_tree().get_first_node_in_group("BeatSync")
	print("Sprite texture size: ", sprite.texture.get_size())
	land_sound.play()
	
	var shape := CircleShape2D.new()
	shape.radius = radius
	collision.shape = shape

	var texture_half_size: float = sprite.texture.get_size().x / 2.0
	sprite.scale = Vector2(radius / texture_half_size, radius / texture_half_size)
	sprite.modulate = Color(1.0, 0.2, 0.2, 0.6)

	## Connect enter/exit signals for lingering zone
	area_entered.connect(_on_area_entered)
	area_exited.connect(_on_area_exited)

	## Apply initial landing hit
	await get_tree().process_frame
	_apply_landing_effects()

	## Fade in visual to show linger
	_show_linger_visual()

	## Count beats then disappear
	last_beat = beat_sync.beat if beat_sync else 0.0


func _process(_delta: float) -> void:
	if beat_sync == null:
		return

	var current_beat := beat_sync.beat
	if current_beat > last_beat:
		last_beat = current_beat
		beats_elapsed += 1

		_tick_linger_damage()

		if beats_elapsed >= linger_beats:
			_fade_and_free()

# if the player gets hit in during the explosion
func _apply_landing_effects() -> void:
	print("Overlapping bodies: ", get_overlapping_bodies())
	print("Overlapping areas: ", get_overlapping_areas())
	for body in get_overlapping_bodies():
		if body.is_in_group("PlayerObject"):
			body.modify_current_player_health(-int(damage))
			_apply_dot(body)
			_apply_slow(body)
			var camera = get_tree().get_first_node_in_group("CameraControl")
			if camera: camera.add_trauma(1) 
			affected_players.append(body)

var is_alive: bool = true

# if player enters the linger AOE
func _on_area_entered(area) -> void:
	## Checker to see what enters area
	print("Area entered: ", area.name, " | parent: ", area.get_parent().name, 
		  " | in PlayerObject group: ", area.get_parent().is_in_group("PlayerObject"))
	var body = area.get_parent()
	if body and body.is_in_group("PlayerObject") and body not in affected_players:
		body.modify_current_player_health(-int(damage))
		_apply_dot(body)
		_apply_slow(body)
		affected_players.append(body)


func _on_area_exited(area) -> void:
	#print("Area exited: ", area.name, " | parent: ", area.get_parent().name)
	var body = area.get_parent()
	if body and body in affected_players:
		affected_players.erase(body)


func _tick_linger_damage() -> void:
	## Deal small damage every beat to anyone still standing in the zone
	for body in get_overlapping_bodies():
		if body.is_in_group("PlayerObject"):
			body.modify_current_player_health(-int(dot_damage_per_beat))

# Applies DOT for the duration
func _apply_dot(player: PlayerCharacter) -> void:
	var dot_beats := 0
	var dot_last_beat := beat_sync.beat if beat_sync else 0.0
	while dot_beats < dot_duration_beats:
		await get_tree().process_frame
		if not is_alive or beat_sync == null or not is_instance_valid(player):
			break
		var current_beat := beat_sync.beat
		if current_beat > dot_last_beat:
			dot_last_beat = current_beat
			dot_beats += 1
			player.modify_current_player_health(-int(dot_damage_per_beat))

# Applies Slow for the duration
func _apply_slow(player: PlayerCharacter) -> void:
	if not is_instance_valid(player):
		return
	var original_speed := player.maxMoveSpeed
	player.moveSpeed *= slow_multiplier
	var slow_beats := 0
	var slow_last_beat := beat_sync.beat if beat_sync else 0.0
	while slow_beats < slow_duration_beats:
		await get_tree().process_frame
		if not is_alive or beat_sync == null or not is_instance_valid(player):
			break
		var current_beat := beat_sync.beat
		if current_beat > slow_last_beat:
			slow_last_beat = current_beat
			slow_beats += 1
	if is_instance_valid(player):
		player.moveSpeed = original_speed


func _show_linger_visual() -> void:
	## Pulse the visual to show the zone is active
	sprite.modulate = Color(0.885, 0.885, 0.877, 0.6)
	if linger_tween:
		linger_tween.kill()
	linger_tween = create_tween()
	linger_tween.set_loops()
	linger_tween.tween_property(sprite, "modulate:a", 0.2, 0.4)
	linger_tween.tween_property(sprite, "modulate:a", 0.8, 0.4)


func _fade_and_free() -> void:
	is_alive = false
	if linger_tween:
		linger_tween.kill()
	var tween := create_tween()
	tween.tween_property(sprite, "modulate:a", 0.0, 0.4)
	await tween.finished
	queue_free()
