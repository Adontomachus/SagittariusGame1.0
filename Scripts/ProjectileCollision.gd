class_name ProjectileCommon
extends Area2D

signal set_projectile_modulate(color: Color)

enum ProjectileSide {
	Player,
	Enemy
}

@export var projectileSide = ProjectileSide.Player
var projectileVelocity
# Measured in seconds
var projectileLifetime
var projectile_damage: int = 5

func _ready():
	projectileVelocity = 762
	projectileLifetime = 50
	
	# Used for world collision
	self.body_entered.connect(func(body: Node2D) -> void:
		if (body.is_in_group("MapObstacle")):
			queue_free()
	)

	self.area_entered.connect(func(area) -> void:
		if (projectileSide == ProjectileSide.Player):
			if area is EnemyProjectileHitbox: #(area.is_in_group("EnemyObject")):
				area.modify_enemy_health(-projectile_damage)
				queue_free()

		if (projectileSide == ProjectileSide.Enemy):
			if area is PlayerCharacter: #(area.is_in_group("PlayerObject")):
				area.increment_player_health(-projectile_damage)
				queue_free()
	)
	
func _process(delta):
	projectileLifetime -= 60 * delta
	if (projectileLifetime < 0):
		queue_free()

func _physics_process(delta):
	position += transform.x * projectileVelocity * delta

func change_damage(damage: int) -> void:
	projectile_damage = damage

func change_projectile_side(new_side: ProjectileSide) -> void:
	projectileSide = new_side

func change_projectile_modulation(color: Color) -> void:
	set_projectile_modulate.emit(color)