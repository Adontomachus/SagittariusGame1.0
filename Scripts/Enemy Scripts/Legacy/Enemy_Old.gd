class_name EnemyCommon
extends CharacterBody2D

# HP Bar Stuff #
signal toggle_healthbar_visibility(visible: bool)
signal send_maximum_health_value(max_health: int)
signal send_current_health_value(health: int)

# BEHAVIOR TYPE
enum EnemyBehavior {
	Chasing,
	Circling,
	Patrolling,
	Recovering,
	Shooting,
	Strafing,
	Closing,
	Positioning
}

# BEHAVIOR ENUMERATOR TYPE
@export var _enemyBehavior: EnemyBehavior = EnemyBehavior.Chasing
@export var navAgent: NavigationAgent2D #= $Pathfinding

# The enemy's target. Usually the player, but it could also be an objective.
var target: CharacterBody2D

# STATISTICS
var stamina: float:
	set(value):
		stamina = clampf(value, 0.0, maxStamina)
	get:
		return stamina
## The random range of the entity's maximum stamina
@export var stamina_range: Vector2 = Vector2(2, 5)
var maxStamina: float = randf_range(2,5)

# VELOCITY
var currentMoveSpeed
@export var maxMoveSpeed: float = 100.0

# VITALITY
@export_group("Vitality Stats")
@export var healthPoints: int
@export var maxHealthPoints: int = 80
@export var meleeTickRate: int = 60

# PATHFINDING MECHANICS
@export_group("Pathfinding Variables")
@export var aroundPlayerRadius = 300
@export var repositioningTimer: float
@export var maxRepositioningTimer: float = 30

# START
func _ready():
	# maxHealthPoints = BeatSync.tempo

	# Set enemy stats
	maxStamina = randf_range(stamina_range.x, stamina_range.y)
	stamina = maxStamina
	currentMoveSpeed = maxMoveSpeed
	healthPoints = maxHealthPoints

	# Setup healthbar
	toggle_healthbar_visibility.emit(false) # Hide the health bar until damaged
	send_maximum_health_value.emit(maxHealthPoints)
	send_current_health_value.emit(healthPoints)
	
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

func reposition(playerRadius):
	#print(stamina)
	if target:
		var randomPosition = Vector2(randf_range(-playerRadius,playerRadius), randf_range(-playerRadius,playerRadius))
		navAgent.target_position = target.global_position + randomPosition
	#var randomPosition = Vector2(randf_range(-maxPathRange,maxPathRange), randf_range(-maxPathRange,maxPathRange))
	#navTimer = 0
	#navPosition = player.global_position + randomPosition
	#navAgent.target_position = player.global_position + randomPosition

# CHASE PLAYER
func _physics_process(delta):
	#print(stamina)
	
	# Recovery Mode
	if (_enemyBehavior == EnemyBehavior.Recovering):
		recoveryMode(2 * delta)
		return
	
	stamina -= delta

	#Enter Recovery Mode when stamina reaches zero
	if stamina <= 0:
		_enemyBehavior = EnemyBehavior.Recovering
		velocity = Vector2.ZERO
		return
	
	# Chasing Mode
	if (_enemyBehavior == EnemyBehavior.Chasing):
		find_target()

	# Movement
	var targetLocation = navAgent.get_next_path_position()
	var new_velocity = global_position.direction_to(targetLocation) * currentMoveSpeed
	velocity = new_velocity
	if (navAgent.avoidance_enabled):
		navAgent.set_velocity(new_velocity)
	else:
		_on_navigation_agent_2d_velocity_computed(new_velocity)
	
	# Positioning Mode
	if _enemyBehavior == EnemyBehavior.Positioning:
		repositioningTimer -= 8 * delta
		if repositioningTimer < 0:
			repositioningTimer = maxRepositioningTimer
			reposition(aroundPlayerRadius)
		
	# TESTING PURPOSES
	#if (BeatSync.lastBeat < BeatSync.beat):
	#	print("Attack!")
		
	move_and_slide()

# RECOVERY MODE
func recoveryMode(recoverySpeed: float) -> void:
	stamina += recoverySpeed
	if stamina >= maxStamina:
		recovered_mode()

## Behaviour after recovery
func recovered_mode() -> void:
	_enemyBehavior = EnemyBehavior.Chasing

func modify_health(increment: int) -> void:
	healthPoints += increment
	send_current_health_value.emit(healthPoints)
	toggle_healthbar_visibility.emit(healthPoints < maxHealthPoints)
	if (healthPoints < 0):
		queue_free()

func _on_navigation_agent_2d_velocity_computed(safe_velocity):
	velocity = safe_velocity
