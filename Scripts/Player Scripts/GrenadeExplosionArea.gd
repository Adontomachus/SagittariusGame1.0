class_name GrenadeExplosion
extends Area2D

enum ProjectileSide {
	Player,
	Enemy
}

# Camera variable for camera shake
@export var camera : CameraControl


@export_category("Grenade Explosion Statistics")
@export var aoe_damage: float = 60.0
@export var explosion_radius: float = 120.0
@export var lifetime: float = 1

@onready var area_indicator: AnimationPlayer = $AnimationPlayer
@onready var explosion_sound: AudioStreamPlayer2D = $ExplosionSound
@onready var explosion_sprite: Sprite2D = $ExplosionSprite
@onready var ripple_fade: AnimationPlayer = $RippleFade

# Visuals
@export var explosion_particles: PackedScene

func _ready() -> void:
	ripple_face.play("Fade")
	## Emit Particles
	var blast = explosion_particles.instantiate()
	blast.position = explosion_sprite.get_global_position()
	get_tree().get_root().call_deferred("add_child", blast)
	
	## Resize collision circle to match explosion radius
	var shape := CircleShape2D.new()
	shape.radius = explosion_radius
	$CollisionShape2D.shape = shape

	area_indicator.play("GrenadeExplode")
	
	explosion_sound.play()

	self.area_entered.connect(func(area) -> void:
		if area is EnemyProjectileHitbox:
			PointSystemScript.total_damage_dealt += aoe_damage
			area.modify_enemy_health(-aoe_damage)
			area.show_aoe_feedback(aoe_damage)
	)
	
	## Shakes the camera
	var camera = get_tree().get_first_node_in_group("CameraControl")
	if camera: camera.add_trauma(0.5) 
	
	await get_tree().create_timer(lifetime).timeout
	queue_free()

func change_damage(damage: float) -> void:
	aoe_damage = damage


func change_radius(radius: float) -> void:
	explosion_radius = radius
