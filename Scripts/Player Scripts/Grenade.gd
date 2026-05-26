class_name Grenade
extends RigidBody2D

@export var explosion_radius: float = 120.0
@export var explosion_damage: float = 80.0
@export var fuse_time: float = 1.0
@export var arc_height: float = 80.0		# how high the visual arc peaks

@onready var sprite: Sprite2D = $Sprite2D
@onready var fuse_timer: Timer = $FuseTimer

var explosion_scene: PackedScene = preload("res://Objects/Instances With Collision/GrenadeExplosion.tscn")

## Set by the player on instantiation
var start_position: Vector2
var target_position: Vector2
var travel_time: float = 0.0
var elapsed: float = 0.0
var is_travelling: bool = false


func _ready() -> void:
	collision_layer = 0
	collision_mask = 0
	fuse_timer.wait_time = fuse_time
	gravity_scale = 0		
	lock_rotation = true


func launch(from: Vector2, to: Vector2) -> void:
	start_position = from
	target_position = to
	travel_time = fuse_time
	elapsed = 0.0
	is_travelling = true
	global_position = from


func _physics_process(delta: float) -> void:
	if not is_travelling:
		return

	elapsed += delta
	var t := clampf(elapsed / travel_time, 0.0, 1.0)

	## Lerp along the ground path
	var flat_position := start_position.lerp(target_position, t)

	## Add arc offset using a parabola: peaks at t=0.5, zero at t=0 and t=1
	var arc_offset := -arc_height * 4.0 * t * (t - 1.0)

	## Apply as a visual Y offset (up is negative in Godot 2D)
	global_position = flat_position + Vector2(0, -arc_offset)

	## Scale sprite to fake depth — grows as it "lands"
	var scale_value := lerpf(0.4, 1.0, t)
	sprite.scale = Vector2(scale_value, scale_value)

	## Spin the sprite for visual flair
	sprite.rotation += delta * 5.0

	if t >= 1.0:
		is_travelling = false
		_explode()


func _explode() -> void:
	var explode_position := global_position
	## Spawn explosion effect
	var explosion = explosion_scene.instantiate()
	get_tree().get_root().call_deferred("add_child", explosion)
	
	await get_tree().process_frame
	explosion.global_position = explode_position
	explosion.change_damage(explosion_damage)
	explosion.change_radius(explosion_radius)
	
	queue_free()
