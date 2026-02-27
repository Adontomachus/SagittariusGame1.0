class_name ExperienceParticle
extends Area2D

var movespeed = randf_range(5,500)
var velocity: Vector2
var pointsAmount = 150
var homeTowardsPlayer = false
var chaseTarget = false
@onready var player: Node2D
@onready var objectTarget: Node2D
func _ready():
	objectTarget = get_tree().get_first_node_in_group("PlayerObject")
	print("Found: ", objectTarget)
	rotation_degrees = randf_range(0,360)
	pass
	
	self.area_entered.connect(func(area) -> void:
		if area is PlayerProjectileHitbox:
		# Since the player score script is global and autoloaded, we will increment it from here
		# along with the point orb's point amount variable
			PointSystemScript.playerScore += pointsAmount
			queue_free()
		)


func _physics_process(delta):
	# objectTarget = get_tree().get_first_node_in_group("PlayerObject")
	# print("FOUND AN OBJECT: " , objectTarget)
	#if (player):
	#	playerLOS.target_position = player.global_position
	#	if (playerLOS.is_colliding()):
	#		var collisionpoint = playerLOS.get_collision_point()
	#		print ("xp sees the player!")
	#get_parent().get_node("Player")
	#OFFICIAL SCRIPT
	position += transform.x * movespeed * delta
	movespeed -= 300 * delta
	if (movespeed <= 0):
		movespeed += 800 * delta
		var objectdirection = global_position.direction_to(objectTarget.global_position)
		var target = objectTarget.global_position
		position = position.move_toward(target, movespeed * delta)

	#	movespeed -= 300 * delta
		
	if GlobalBeatSync.lastBeat < GlobalBeatSync.beat:
		pass




func _on_area_2d_area_entered(area: Area2D) -> void:
	pass # Replace with function body.



	
