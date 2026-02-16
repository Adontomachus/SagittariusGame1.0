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
@export var _enemyType = EnemyType.Fodder
@export var _enemyBehavior = EnemyBehavior.Chasing
# TEMPORARY
@onready var node: Node2D = $".."
@export var player: CharacterBody2D


@onready var selfEnemySprite: Sprite2D = $Sprite
@onready var navAgent: NavigationAgent2D = $Pathfinding
@onready var projectile_hitbox: Area2D = $ProjectileHitbox

# STATISTICS
var stamina
var maxStamina = 8
# Velocity
var currentMoveSpeed
var maxMoveSpeed = 100
var healthPoints
var maxHealthPoints = 80
var meleeTickRate = 60

# START
func _ready():
	stamina = maxStamina
	currentMoveSpeed = maxMoveSpeed
	healthPoints = maxHealthPoints
	pass

func _process(delta):
	print(stamina)
	player = get_tree().get_first_node_in_group("PlayerObject")
	if (healthPoints < 0):
		queue_free()
		
	#FINDING TARGET FUNCTION
func find_target() -> void:
	if (player):
		navAgent.target_position = player.global_position



# FINDING TARGET FUNCTION, NAVIGATION AGENT SETUP
func _navigationsetup():
	await get_tree().physics_frame
	if player:
		return

	# CHASE PLAYER
func _physics_process(delta):
	# Recovery Mode
	if (_enemyBehavior == EnemyBehavior.Recovering):
		stamina += 2 * delta
		velocity = Vector2.ZERO
	
	# Chasing Script
	elif (_enemyBehavior == EnemyBehavior.Chasing):
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


func _on_navigation_agent_2d_velocity_computed(safe_velocity):
	velocity = safe_velocity
	pass # Replace with function body.

func _on_projectile_hitbox_area_entered(area: Area2D) -> void:
	if (area.is_in_group("PlayerProjectile")):
		queue_free()
	pass # Replace with function body.
