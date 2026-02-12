extends CharacterBody2D


@onready var player: CharacterBody2D = $"../Player"
@onready var selfEnemySprite: Sprite2D = $Sprite2D
@onready var navAgent: NavigationAgent2D = $NavigationAgent2D

#STATISTICS
var moveSpeed = 15
var healthPoints
var maxHealthPoints = 80
var navTimer

func _ready():
	healthPoints = maxHealthPoints
	pass

func _process(delta):
	player = get_tree().get_first_node_in_group("PlayerObject")
	if (healthPoints < 0):
		queue_free()
		
#FINDING TARGET FUNCTION
func find_target():
	if (player):
		navTimer = 0
		#navPosition = player.global_position + randomPosition
		navAgent.target_position = player.global_position

	
	#NAVIGATION AGENT SETUP
func _navigationsetup():
	await get_tree().physics_frame
	if player:
		return
	pass






	
