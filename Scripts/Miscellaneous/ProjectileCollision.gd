class_name ProjectileCommon
extends Area2D

## For Kapre Shot
@export var is_kapre_shot: bool = false
var kapre_smoke_scene := preload("res://Objects/Particle Effects/KapreSmokeEffect.tscn")
var kapre_aoe_scene := preload("res://Objects/Instances With Collision/SplashDamage.tscn")
var kapre_damage: float = 0.0

signal set_projectile_modulate(color: Color)
var hit_combo_value: float = 0.0

enum ProjectileSide {
	Player,
	Enemy
}

enum DamageType {
	SingleTarget,
	AreaOfEffect
}

enum ProjectileVelocityType {
	Constant,
	Slowing
}
@export var projectile_sprite: Node2D
# Projectile properties containing projectile side and velocity types
@export_category("Projectile Properties")
@export var projectileSide = ProjectileSide.Player
@export var damage_type = DamageType.SingleTarget
@export var velocity_type = ProjectileVelocityType.Constant

# Projectile Statistics containing velocity, lifetime and damage with critical hit boolean
@export_category("Projectile Statistics")
@export var projectileVelocity: float
@export var projectileLifetime: float
@export var criticalHit: bool
@export var projectile_damage: float = 5

@export_category("Glow Effects")
@export var faint_glow: PointLight2D
@export var enemy_glow: PointLight2D

@export var emitter: CPUParticles2D 
@onready var particles: GPUParticles2D = $OrbitingParticles

@onready var hit_noise : AudioStreamPlayer = $EnemyHitSound

var wallHitEffects := preload("res://Objects/Particle Effects/WallHitEffect.tscn")
var unitHitEffects := preload("res://Objects/Particle Effects/UnitHitEffect.tscn")

var damageNumber := preload("res://Objects/UI Elements/DamageNumbers.tscn")
var enemyDamageNumber := preload("res://Objects/UI Elements/EnemyDamageNumbers.tscn")

# Damage number positioning
var initPosition: Vector2 = Vector2(-125, -105)
# Boolean for being able to damage instances
var can_damage: bool = true

#TESTING PURPOSES
var testEffects := preload("res://Objects/Particle Effects/CollectEffect.tscn")

func set_projectile_size(size_multiplier: float) -> void:
	scale = Vector2.ONE * size_multiplier

func _setup_visuals() -> void:
	if projectileSide == ProjectileSide.Player:
		faint_glow.visible = true
		enemy_glow.visible = false
		if particles:
			particles.visible = true
	elif projectileSide == ProjectileSide.Enemy:
		faint_glow.visible = false
		enemy_glow.visible = true
		if particles:
			particles.visible = false
			
func _ready():
	call_deferred("_setup_visuals")
	## Check if the projectile velocity type is constant or changing.
	if damage_type == DamageType.SingleTarget:
		# Lambda functions used for world collision for single target enumerator
		self.body_entered.connect(func(body: Node2D) -> void:
			if (body.is_in_group("MapObstacle")):
				var hitEffect = wallHitEffects.instantiate()
				hitEffect.position = self.get_global_position()
				get_tree().get_root().call_deferred("add_child", hitEffect)
				if is_kapre_shot:
					_trigger_kapre_explosion()
				#hit_noise.play()
				#hide()
				#await hit_noise.finished
				queue_free()
		)

		self.area_entered.connect(func(area) -> void:
			if projectileSide == ProjectileSide.Player:
				if area is EnemyProjectileHitbox:
					if can_damage:
						## Call modify_enemy_health once only
						area.modify_enemy_health(-projectile_damage)

						## Harana Flame — on perfect hits only (hit_combo_value >= 40 means perfect)
						var player := get_tree().get_first_node_in_group("PlayerObject") as PlayerCharacter
						if player and player.harana_flame and hit_combo_value >= 40.0:
							var enemy : Node = area.get_parent()
							player._apply_harana_flame(enemy)

						var combo_ui := get_tree().get_first_node_in_group("ComboUIFeedback")
						if combo_ui:
							combo_ui.on_particle_arrived(hit_combo_value)

						## Hit feedback
						var hitEffect = unitHitEffects.instantiate()
						hitEffect.position = self.get_global_position()
						get_tree().get_root().call_deferred("add_child", hitEffect)

						## Damage number
						var damageFeedback = damageNumber.instantiate()
						damageFeedback.position = self.get_global_position() + initPosition
						damageFeedback.damage_value = projectile_damage
						PointSystemScript.total_damage_dealt += projectile_damage
						get_tree().get_root().call_deferred("add_child", damageFeedback)
						if is_kapre_shot:
							_trigger_kapre_explosion()
						can_damage = false
						hit_noise.play()
						hide()

					await hit_noise.finished
					queue_free()

			if projectileSide == ProjectileSide.Enemy:
				if area is PlayerProjectileHitbox:
					var hitEffect = unitHitEffects.instantiate()
					hitEffect.position = self.get_global_position()
					get_tree().get_root().call_deferred("add_child", hitEffect)

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
					PointSystemScript.total_damage_dealt += projectile_damage
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
	if velocity_type == ProjectileVelocityType.Slowing:
		_fade_projectile_velocity(delta)

func change_velocity(new_velocity: float) -> void:
	projectileVelocity = new_velocity

func change_lifetime(new_lifetime: float) -> void:
	projectileLifetime = new_lifetime

func _physics_process(delta):
	var angle := fposmod(rotation_degrees, 360.0)
	if particles:
		if angle > 90.0 and angle < 270.0:
			particles.scale.y = -1.0
		else:
			particles.scale.y = 1.0
	position += transform.x * projectileVelocity * delta

func _fade_projectile_velocity(delta) -> void:
	var speed_tween = create_tween()
	speed_tween.tween_property(self, "projectileVelocity", 0, 2)
	pass

# Function for changing damage value outside of exported value
func change_damage(damage: int) -> void:
	projectile_damage = damage

# Changes the projectile's alignment
func change_projectile_side(new_side: ProjectileSide) -> void:
	projectileSide = new_side

# Changes the projectile's color for identification
func change_projectile_modulation(color: Color) -> void:
	modulate = color

func _trigger_kapre_explosion() -> void:
	var impact_pos := global_position

	## Damage AoE at impact point
	var aoe = kapre_aoe_scene.instantiate()
	aoe.change_damage(kapre_damage)
	aoe.position = impact_pos
	get_tree().get_root().call_deferred("add_child", aoe)
	var world_parent = get_tree().current_scene.get_node_or_null(
		"GameLevelNode/Stage1/EnemyNavRegion/Map Objects/World"
	)
	## Smoke cloud at impact point
	var smoke = kapre_smoke_scene.instantiate()
	world_parent.add_child(smoke)
	smoke.global_position = impact_pos

	## Camera bump
	var camera := get_tree().get_first_node_in_group("CameraControl")
	if camera:
		camera.add_trauma(0.8)
