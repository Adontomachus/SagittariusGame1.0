class_name ProjectileCommon
extends Area2D

signal set_projectile_modulate(color: Color)

enum ProjectileSide {
	Player,
	Enemy
}

enum DamageType {
	SingleTarget,
	AreaOfEffect
}

#
@export_category("")
@export var projectileSide = ProjectileSide.Player
@export var damage_type = DamageType.SingleTarget

# Projectile Statistics containing velocity, lifetime and damage with critical hit boolean
@export_category("Projectile Statistics")
@export var projectileVelocity: float
@export var projectileLifetime: float
@export var criticalHit: bool
@export var projectile_damage: float = 5
var wallHitEffects := preload("res://Objects/Particle Effects/WallHitEffect.tscn")
var unitHitEffects := preload("res://Objects/Particle Effects/UnitHitEffect.tscn")

var damageNumber := preload("res://Objects/UI Elements/DamageNumbers.tscn")
var enemyDamageNumber := preload("res://Objects/UI Elements/EnemyDamageNumbers.tscn")
# Damage number positioning
var initPosition: Vector2 = Vector2(-125, -105)

#TESTING PURPOSES
var testEffects := preload("res://Objects/Particle Effects/CollectEffect.tscn")


func _ready():
	# projectileVelocity = 762
	# projectileLifetime = 50
	
	if damage_type == DamageType.SingleTarget:
		# Lambda functions used for world collision for single target enumerator
		self.body_entered.connect(func(body: Node2D) -> void:
			if (body.is_in_group("MapObstacle")):
				var hitEffect = wallHitEffects.instantiate()
				hitEffect.position = self.get_global_position()
				get_tree().get_root().call_deferred("add_child", hitEffect)
				queue_free()
		)

		self.area_entered.connect(func(area) -> void:
			if (projectileSide == ProjectileSide.Player):
				if area is EnemyProjectileHitbox: #(area.is_in_group("EnemyObject")):
					area.modify_enemy_health(-projectile_damage)
					#Hit feedback
					var hitEffect = unitHitEffects.instantiate()
					hitEffect.position = self.get_global_position()
					get_tree().get_root().call_deferred("add_child", hitEffect)
					# Damage Number Feedback
					var damageFeedback = damageNumber.instantiate()
					damageFeedback.position = self.get_global_position() + initPosition
					damageFeedback.damage_value = projectile_damage
					get_tree().get_root().call_deferred("add_child", damageFeedback)
					queue_free()

			if (projectileSide == ProjectileSide.Enemy):
				if area is PlayerProjectileHitbox: #(area.is_in_group("PlayerObject")):
					# Hit feedback
					var hitEffect = unitHitEffects.instantiate()
					hitEffect.position = self.get_global_position()
					get_tree().get_root().call_deferred("add_child", hitEffect)
					
					# Enemy Damage Number Feedback
					var enemyDamageFeedback = enemyDamageNumber.instantiate()
					enemyDamageFeedback.position = self.get_global_position() + initPosition
					enemyDamageFeedback.damage_value = projectile_damage
					get_tree().get_root().call_deferred("add_child", enemyDamageFeedback)
					
					area.modify_player_health(-projectile_damage)
					queue_free()
		)
	elif damage_type == DamageType.AreaOfEffect:
		self.area_entered.connect(func(area) -> void:
			if (projectileSide == ProjectileSide.Player):
				if area is EnemyProjectileHitbox: #(area.is_in_group("EnemyObject")):
					area.modify_enemy_health(-projectile_damage)
					#Hit feedback
					var hitEffect = unitHitEffects.instantiate()
					hitEffect.position = self.get_global_position()
					get_tree().get_root().call_deferred("add_child", hitEffect)
					# Damage Number Feedback
					var damageFeedback = damageNumber.instantiate()
					damageFeedback.position = self.get_global_position() + initPosition
					damageFeedback.damage_value = projectile_damage
					if criticalHit: damageFeedback.is_critical_hit = true
					get_tree().get_root().call_deferred("add_child", damageFeedback)


			if (projectileSide == ProjectileSide.Enemy):
				if area is PlayerProjectileHitbox: #(area.is_in_group("PlayerObject")):
					# Hit feedback
					var hitEffect = unitHitEffects.instantiate()
					hitEffect.position = self.get_global_position()
					get_tree().get_root().call_deferred("add_child", hitEffect)
					# Damage Number Feedback
					area.modify_player_health(-projectile_damage)
		)
func _process(delta):
	projectileLifetime -= 60 * delta
	if (projectileLifetime < 0):
		queue_free()

func _physics_process(delta):
	position += transform.x * projectileVelocity * delta

# Function for changing damage value outside of exported value
func change_damage(damage: int) -> void:
	projectile_damage = damage

# Changes the projectile's alignment
func change_projectile_side(new_side: ProjectileSide) -> void:
	projectileSide = new_side

# Changes the projectile's color for identification
func change_projectile_modulation(color: Color) -> void:
	set_projectile_modulate.emit(color)
