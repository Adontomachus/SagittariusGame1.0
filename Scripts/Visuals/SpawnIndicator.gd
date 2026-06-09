class_name SpawnIndicator
extends Node2D

@onready var sprite: Sprite2D = $Sprite2D

@export var reveal_duration: float = 1   ## time to grow from top to bottom
@export var linger_duration: float = 0.2   ## brief pause at full reveal
@export var hide_duration: float = 0.5   ## time to disappear top to bottom

## Color of the indicator
@export var indicator_color: Color = Color(0.8, 0.2, 0.2, 0.8)

var tween: Tween


func _ready() -> void:
	if sprite.material:
		sprite.material = sprite.material.duplicate()
	var mat := sprite.material as ShaderMaterial
	if mat == null:
		push_error("SpawnIndicator: ShaderMaterial not found")
		return
	mat.set_shader_parameter("reveal_progress", 0.0)
	mat.set_shader_parameter("indicator_color", indicator_color)


func play_and_spawn(enemy_scene: PackedScene, spawn_pos: Vector2) -> void:
	print("play_and_spawn started")
	await _reveal()
	## Reveal from bottom to topp
	print("reveal done")
	## Brief linger so player can see it
	await get_tree().create_timer(linger_duration).timeout
	## Spawn the enemy
	_spawn_enemy(enemy_scene, spawn_pos)
	## Hide from top to bottom
	await _hide()
	queue_free()


func _reveal() -> void:
	print("_reveal started")
	var mat := sprite.material as ShaderMaterial
	if mat == null:
		push_error("SpawnIndicator: ShaderMaterial not found")
		return
	var elapsed := 0.0
	while elapsed < reveal_duration:
		elapsed += get_process_delta_time()
		var t := clampf(elapsed / reveal_duration, 0.0, 1.0)
		var progress := ease(t, -2.0)
		mat.set_shader_parameter("reveal_progress", progress)
		print("reveal_progress: ", progress)  ## confirm value is changing
		await get_tree().process_frame
	## Force fully revealed at end
	mat.set_shader_parameter("reveal_progress", 1.0)


func _hide() -> void:
	var mat := sprite.material as ShaderMaterial
	if mat == null:
		return
	var elapsed := 0.0
	while elapsed < hide_duration:
		elapsed += get_process_delta_time()
		var t := clampf(elapsed / hide_duration, 0.0, 1.0)
		## Shrinks from top down 
		mat.set_shader_parameter("reveal_progress", 1.0 - ease(t, 2.0))
		await get_tree().process_frame
	mat.set_shader_parameter("reveal_progress", 0.0)


func _spawn_enemy(enemy_scene: PackedScene, spawn_pos: Vector2) -> void:
	if enemy_scene == null:
		return
	var enemy = enemy_scene.instantiate()
	get_tree().current_scene.add_child(enemy)
	enemy.global_position = spawn_pos
