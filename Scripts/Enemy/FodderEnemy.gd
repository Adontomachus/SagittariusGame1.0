class_name EnemyCommon
extends CharacterBody2D

# ENEMY TYPE
enum EnemyType {
	Fodder,
	Elite,
	Adversary,
	Boss
}

enum EnemyBehavior {
	Chasing,
	Circling,
	Patrolling,
	Recovering
}

# ENUMERATOR TYPE
@export var _enemyType: EnemyType = EnemyType.Fodder
@export var _enemyBehavior: EnemyBehavior = EnemyBehavior.Chasing

@onready var selfEnemySprite: Sprite2D = $Sprite
@onready var navAgent: NavigationAgent2D = $Pathfinding
@onready var projectile_hitbox: Area2D = $ProjectileHitbox

# The enemy's target. Usually the player, but it could also be an objective.
var target: CharacterBody2D


# STATISTICS
var stamina
var maxStamina = randf_range(6,25)

# VELOCITY
var currentMoveSpeed
var maxMoveSpeed = 100

# VITALITY
var healthPoints: int
var maxHealthPoints = 80
var meleeTickRate = 60

# HEALTH BAR
@onready var hpBar: ProgressBar = $HealthBar

# START
func _ready():
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
func find_target() -> void:
	if (target):
		navAgent.target_position = target.global_position

# FINDING TARGET FUNCTION, NAVIGATION AGENT SETUP
func _navigationsetup():
	await get_tree().physics_frame
	if target:
		return

	# CHASE PLAYER
func _physics_process(delta):
	# Recovery Mode
	if (_enemyBehavior == EnemyBehavior.Recovering):
		stamina += 2 * delta
		velocity = Vector2.ZERO
	
	# Chasing Script
	if (_enemyBehavior == EnemyBehavior.Chasing):
		stamina -= delta
		
		find_target()
		var targetLocation = navAgent.get_next_path_position()
		var new_velocity = global_position.direction_to(targetLocation) * currentMoveSpeed
		velocity = new_velocity
		if (navAgent.avoidance_enabled):
			navAgent.set_velocity(new_velocity)
		else:
			_on_navigation_agent_2d_velocity_computed(new_velocity)
			
		# Set to stationary after running out of stamina to recover
		if (stamina < 0):
			_enemyBehavior = EnemyBehavior.Recovering	
		
	move_and_slide()

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
