extends Sprite2D


@onready var playerLOS: RayCast2D = $RayCast2D
var movespeed = randf_range(5,250)
var velocity: Vector2
var xpamount = 8
var homeTowardsPlayer = false
var chaseTarget = false
@onready var player: Node2D
var objectTarget
func _ready():
	rotation_degrees = randf_range(0,360)
	pass
	


func _physics_process(delta):
	
	objectTarget = get_tree().get_first_node_in_group("PlayerObject")
	print("FOUND AN OBJECT: " , objectTarget)
	
	if (player):
		playerLOS.target_position = player.global_position
		if (playerLOS.is_colliding()):
			var collisionpoint = playerLOS.get_collision_point()
			print ("xp sees the player!")
	get_parent().get_node("Player")
	#OFFICIAL SCRIPT
	if (!homeTowardsPlayer):
		position += transform.x * movespeed * delta
		if (movespeed < 0):
			movespeed = 0
			homeTowardsPlayer = true
			chaseTarget = true
		movespeed -= 150 * delta
	if (homeTowardsPlayer):
		if (player):
			movespeed += 5 * delta
			var objectdirection = global_position.direction_to(player.global_position)
			var target = player.global_position
			position = position.move_toward(target, movespeed * delta)
		else:
			print ("Player not found")

	#SCRIPT FOR TEST PURPOSE
	if (chaseTarget):
		if (objectTarget):
			movespeed += 800 * delta
			var objectdirection = global_position.direction_to(objectTarget.global_position)
			var target = objectTarget.global_position
			position = position.move_toward(target, movespeed * delta)
		else:
			print ("Player not found")
		pass
	pass
	
func _find_target_object():
	var target = get_tree().get_nodes_in_group("playerTarget")[0]
	pass
	



func _on_body_entered(body: Node2D):
	if body.is_in_group("PlayerObject"):
		queue_free()
	pass # Replace with function body.
