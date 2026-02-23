class_name EnemyElite
extends EnemyCommon

## Marker2D point, for enemies that shoot projectiles without needing to rotate.
@export var shoot_point: Marker2D #= $ShootPoint

# OFFENSIVE STATISTICS
@export_category("Offense Stats")
@export var attackPower: float
@export var projectile := preload("res://Objects/PrototypeProjectile.tscn")
# This variable is rolled randomly from 0, 10. Higher values 
# give the unit more chance to shoot the player for each beat.
@export var chanceToAttack: float
@export var successfulChanceToAttack: float

# START
func _ready():
	super()

func _physics_process(delta):
	# Makes the unit's shoot point to point at the player
	shoot_point.look_at(target.global_position)	
	
	super(delta)

	# Checks if the navigation agent has reached its destination and stops
	if navAgent.is_navigation_finished():
		_shoot_projectile()
		chanceToAttack = randf_range(0,10)
		velocity = Vector2.ZERO
		_enemyBehavior = EnemyBehavior.Positioning

func reposition(playerRadius) -> void:
	super(playerRadius)
	_enemyBehavior = EnemyBehavior.Closing

func recovered_mode() -> void:
	_enemyBehavior = EnemyBehavior.Closing

#SHOOTING PROJECTILE
func _shoot_projectile(modifier: float = 1.0, color: Color = Color.RED):
	if (GlobalBeatSync.executeAction):
		var projectile_instance = projectile.instantiate()
		projectile_instance.change_damage(attackPower * modifier)
		projectile_instance.change_projectile_side(ProjectileCommon.ProjectileSide.Enemy)
		projectile_instance.change_projectile_modulation(color)
		projectile_instance.position = shoot_point.get_global_position()
		projectile_instance.rotation_degrees = shoot_point.rotation_degrees
		get_tree().get_root().call_deferred("add_child", projectile_instance)
		print_debug("Damage: %s" % (attackPower * modifier))

