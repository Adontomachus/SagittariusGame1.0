class_name EnemyCommon
extends CharacterBody2D
# BEHAVIOR TYPE
enum EnemyBehavior {
	Chasing,
	Circling,
	Patrolling,
	Recovering
}

# BEHAVIOR ENUMERATOR TYPE
@export var _enemyBehavior: EnemyBehavior = EnemyBehavior.Chasing

@onready var selfEnemySprite: Sprite2D = $Sprite
@onready var navAgent: NavigationAgent2D = $Pathfinding
@onready var projectile_hitbox: Area2D = $ProjectileHitbox

# The enemy's target. Usually the player, but it could also be an objective.
var target: CharacterBody2D


# STATISTICS
var stamina
var maxStamina = randf_range(2,5)

# VELOCITY
var currentMoveSpeed
var maxMoveSpeed = 100

# VITALITY
@export_category("Vitality Stats")
@export var healthPoints: float
@export var maxHealthPoints = 80
@export var meleeTickRate = 60

# HEALTH BAR
@onready var hpBar: ProgressBar = $HealthBar

# START
func _ready():
	# maxHealthPoints = BeatSync.tempo
	# Hide the health bar until damaged
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
	#print(stamina)
	if (healthPoints < maxHealthPoints):
		hpBar.visible = true
	#Enter on a recovery mode
	if stamina < 0:
		_enemyBehavior = EnemyBehavior.Recovering
		velocity = Vector2.ZERO
	
	# Recovery Mode
	if (_enemyBehavior == EnemyBehavior.Recovering):
		recoveryMode(2 * delta)
		
	
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
			
	# TESTING PURPOSES
	#if (BeatSync.lastBeat < BeatSync.beat):
	#	print("Attack!")
		
	move_and_slide()

# RECOVERY MODE
func recoveryMode(recoverySpeed: float) -> void:
	stamina += recoverySpeed
	if stamina > maxStamina: 
		stamina = maxStamina
		_enemyBehavior = EnemyBehavior.Chasing	
	


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
