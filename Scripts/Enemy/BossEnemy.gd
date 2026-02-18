class_name EnemyBoss
extends CharacterBody2D
# BEHAVIOR TYPE
enum EnemyBehavior {
	Shooting,
	Strafing,
	Closing,
	Recovering
}

# BEHAVIOR ENUMERATOR TYPE
@export var _enemyBehavior: EnemyBehavior = EnemyBehavior.Closing

@onready var selfEnemySprite: Sprite2D = $Sprite
@onready var navAgent: NavigationAgent2D = $Pathfinding
@onready var projectile_hitbox: Area2D = $ProjectileHitbox


# The enemy's target. Usually the player, but it could also be an objective.
var target: CharacterBody2D


# STATISTICS
var stamina
var maxStamina = randf_range(200,500)


# PATHFINDING MECHANICS
@export_category("Pathfinding Variables")
@export var aroundPlayerRadius = 300
@export var repositioningTimer: float
@export var maxRepositioningTimer: float = 30

# VELOCITY
var currentMoveSpeed
var maxMoveSpeed = 35

# VITALITY
@export_category("Vitality Stats")
@export var healthPoints: int
@export var maxHealthPoints = 4000
@export var meleeTickRate = 60

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



# FINDING TARGET FUNCTION, NAVIGATION AGENT SETUP
func _navigationsetup():
	await get_tree().physics_frame
	if target:
		return

func reposition(playerRadius):
	#print(stamina)
	if (target):
		var randomPosition = Vector2(randf_range(-playerRadius,playerRadius), randf_range(-playerRadius,playerRadius))
		navAgent.target_position = target.global_position + randomPosition
	#var randomPosition = Vector2(randf_range(-maxPathRange,maxPathRange), randf_range(-maxPathRange,maxPathRange))
	#navTimer = 0
	#navPosition = player.global_position + randomPosition
	#navAgent.target_position = player.global_position + randomPosition
			


# CHASE PLAYER
func _physics_process(delta):
	
	#region For constant navigation agent checking
	var targetLocation = navAgent.get_next_path_position()
	var new_velocity = global_position.direction_to(targetLocation) * currentMoveSpeed
	velocity = new_velocity
	if (navAgent.avoidance_enabled):
		navAgent.set_velocity(new_velocity)
	else:
		_on_navigation_agent_2d_velocity_computed(new_velocity)
	#endregion
		
	repositioningTimer -= 8 * delta
	if repositioningTimer < 0:
		repositioningTimer = maxRepositioningTimer
		reposition(aroundPlayerRadius)
			
		
	move_and_slide()

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
