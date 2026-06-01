class_name GrenadeExplosion
extends Area2D

enum ProjectileSide {
	Player,
	Enemy
}

@export_category("Grenade Explosion Statistics")
@export var aoe_damage: float = 60.0
@export var explosion_radius: float = 120.0
@export var lifetime: float = 0.6

@onready var area_indicator: AnimationPlayer = $AnimationPlayer
@onready var explosion_sound: AudioStreamPlayer2D = $ExplosionSound


func _ready() -> void:
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

	await get_tree().create_timer(lifetime).timeout
	queue_free()


func change_damage(damage: float) -> void:
	aoe_damage = damage


func change_radius(radius: float) -> void:
	explosion_radius = radius
