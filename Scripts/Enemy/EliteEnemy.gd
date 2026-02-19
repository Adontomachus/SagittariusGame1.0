class_name EnemyElite
extends CharacterBody2D
# BEHAVIOR TYPE
enum EnemyBehavior {
	Shooting,
	Positioning,
	Closing,
	Recovering
}

# BEHAVIOR ENUMERATOR TYPE
@export_category("Behavior Phase")
@export var _enemyBehavior: EnemyBehavior = EnemyBehavior.Closing

@onready var selfEnemySprite: Sprite2D = $Sprite
@onready var navAgent: NavigationAgent2D = $Pathfinding
@onready var projectile_hitbox: Area2D = $ProjectileHitbox

# The enemy's target. Usually the player, but it could also be an objective.
var target: CharacterBody2D
# Marker2D point, for enemies that shoot projectiles without needing to rotate.
@onready var shoot_point: Marker2D = $ShootPoint


# STATISTICS
var stamina
var maxStamina = randf_range(2,5)

# VELOCITY
var currentMoveSpeed
var maxMoveSpeed = 350

# UNIQUE PATHFINDING STATISTICS
@export_category("Pathfinding Variables")
@export var aroundPlayerRadius = 500
@export var repositioningTimer: float
@export var maxRepositioningTimer: float = 30

# VITALITY
@export_category("Vitality Stats")
@export var healthPoints: int
@export var maxHealthPoints = 80
@export var meleeTickRate = 60

# OFFENSIVE STATISTICS
@export_category("Offense Stats")
@export var attackPower: float
@export var projectile := preload("res://Objects/PrototypeProjectile.tscn")
# This variable is rolled randomly from 0, 10. Higher values 
# give the unit more chance to shoot the player for each beat.
@export var chanceToAttack: float
@export var successfulChanceToAttack: float
# HEALTH BAR
@onready var hpBar: ProgressBar = $HealthBar

# START
func _ready():
	hpBar.visible = false
	# Set enemy stats
	stamina = maxStamina
	currentMoveSpeed = maxMoveSpeed
	healthPoints = maxHealthPoints

	# Setup healthbar
	hpBar.max_value = maxHealthPoints
	hpBar.value = healthPoints
	
	
	
	# Get player for navigation and targeting
	target = get_tree().get_first_node_in_group("PlayerObject")
		
#FINDING TARGET FUNCTION



# FINDING TARGET FUNCTION, NAVIGATION AGENT SETUP
func _navigationsetup():
	await get_tree().physics_frame
	if target:
		return

func reposition(playerRadius):
	#print(stamina)
	if _enemyBehavior == EnemyBehavior.Positioning:
		if target:
			var randomPosition = Vector2(randf_range(-playerRadius,playerRadius), randf_range(-playerRadius,playerRadius))
			navAgent.target_position = target.global_position + randomPosition
	#var randomPosition = Vector2(randf_range(-maxPathRange,maxPathRange), randf_range(-maxPathRange,maxPathRange))
	#navTimer = 0
	#navPosition = player.global_position + randomPosition
	#navAgent.target_position = player.global_position + randomPosition

func _physics_process(delta):
	
	# Makes the unit's shoot point to point at the player
	shoot_point.look_at(target.global_position)
	
	#region For constant navigation agent checking
	var targetLocation = navAgent.get_next_path_position()
	var new_velocity = global_position.direction_to(targetLocation) * currentMoveSpeed
	velocity = new_velocity
	if (navAgent.avoidance_enabled):
		navAgent.set_velocity(new_velocity)
	else:
		_on_navigation_agent_2d_velocity_computed(new_velocity)
	#endregion
	
	#region Sets the health bar to visible when damaged, and reposition when timer runs out
	if (healthPoints < maxHealthPoints):
		hpBar.visible = true
	repositioningTimer -= 8 * delta
	if repositioningTimer < 0:
		repositioningTimer = maxRepositioningTimer
		reposition(aroundPlayerRadius)
	#endregion
	
	# Checks if the navigation agent has reached its destination and stops
	if navAgent.is_navigation_finished():
		_shoot_projectile()
		chanceToAttack = randf_range(0,10)
		velocity = Vector2.ZERO
		
	
	move_and_slide()

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

# RECOVERY MODE
func recoveryMode(recoverySpeed: float) -> void:
	stamina += recoverySpeed


func modify_health(increment: int) -> void:
	healthPoints += increment
	hpBar.value = healthPoints
	if (healthPoints < 0):
		queue_free()

func _on_navigation_agent_2d_velocity_computed(safe_velocity):
	velocity = safe_velocity
#func _on_projectile_hitbox_area_entered(area: Area2D) -> void:
#	if (area.is_in_group("PlayerProjectile")):
#		healthPoints -= 36
