extends CharacterBody2D

# TEMPORARY
@onready var node: Node2D = $".."

@onready var player: CharacterBody2D = $"../Player"
@onready var selfEnemySprite: Sprite2D = $Sprite2D
@onready var navAgent: NavigationAgent2D = $NavigationAgent2D

#STATISTICS
var moveSpeed = 40
var healthPoints
var maxHealthPoints = 80

# START
func _ready():
	healthPoints = maxHealthPoints
	pass

func _process(delta):
	# player = get_tree().get_first_node_in_group("PlayerObject")
	if (healthPoints < 0):
		queue_free()
		
		
	#FINDING TARGET FUNCTION
func find_target() -> void:
	navAgent.target_position = player.global_position

	
	#NAVIGATION AGENT SETUP
func _navigationsetup():
	await get_tree().physics_frame
	if player:
		return

	# CHASE PLAYER TEST
func _physics_process(delta):
	find_target()
	var targetLocation = navAgent.get_next_path_position()
	var new_velocity = global_position.direction_to(targetLocation) * moveSpeed
	velocity = new_velocity
	if (navAgent.avoidance_enabled):
		navAgent.set_velocity(new_velocity)
	move_and_slide()




	
