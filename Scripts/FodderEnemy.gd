extends CharacterBody2D

# TEMPORARY
@onready var node: Node2D = $".."
@export var player: CharacterBody2D


@onready var selfEnemySprite: Sprite2D = $Sprite
@onready var navAgent: NavigationAgent2D = $Pathfinding

# STATISTICS
var moveSpeed = 40
var healthPoints
var maxHealthPoints = 80

# START
func _ready():
	healthPoints = maxHealthPoints
	pass

func _process(delta):
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
	find_target()
	var targetLocation = navAgent.get_next_path_position()
	var new_velocity = global_position.direction_to(targetLocation) * moveSpeed
	velocity = new_velocity
	if (navAgent.avoidance_enabled):
		navAgent.set_velocity(new_velocity)
	else:
		_on_navigation_agent_2d_velocity_computed(new_velocity)
	move_and_slide()

func _on_navigation_agent_2d_velocity_computed(safe_velocity):
	velocity = safe_velocity
	pass # Replace with function body.




	
