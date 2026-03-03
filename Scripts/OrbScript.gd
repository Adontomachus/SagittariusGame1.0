class_name ExperienceParticle
extends Area2D

var movespeed = randf_range(5,500)
var velocity: Vector2
var pointsAmount = 150
var homeTowardsPlayer = false
var chaseTarget: bool = false
@onready var player: Node2D
@onready var objectTarget: Node2D

var collEffect := preload("res://Objects/Particle Effects/CollectEffect.tscn")
func _ready():
	objectTarget = get_tree().get_first_node_in_group("PlayerObject")
	print("Found: ", objectTarget)
	rotation_degrees = randf_range(0,360)
	pass
	self.area_entered.connect(func(area) -> void:
		if area is PlayerProjectileHitbox:
		# Since the player score script is global and autoloaded, we will increment it from here
		# along with the point orb's point amount variable
			var hitEffect = collEffect.instantiate()
			hitEffect.position = self.get_global_position()
			get_tree().get_root().call_deferred("add_child", hitEffect)
			PointSystemScript.playerScore += pointsAmount
			emit_effects()
			queue_free()
		)


func _physics_process(delta):
	
	if GlobalBeatSync.lastBeat < GlobalBeatSync.beat:
		pass

	#OFFICIAL SCRIPT
	position += transform.x * movespeed * delta
	if !chaseTarget:
		movespeed -=  300 * delta
	if (movespeed <= 0):
		chaseTarget = true
		if (chaseTarget):
			movespeed += 355 * delta
			look_at(objectTarget.global_position)

		#if (chaseTarget):

			#movespeed += 750 * delta
	#	velocity = Vector2.ZERO
	#	movespeed += 800 * delta
	#	var objectdirection = global_position.direction_to(objectTarget.global_position)
	#	var target = objectTarget.global_position
	#	position = position.move_toward(target, movespeed * delta)
	#	movespeed -= 300 * delta



func emit_effects():
	var collectEffect = collEffect.instantiate()
	collectEffect.position = self.get_global_position()
	get_tree().get_root().call_deferred("add_child", collEffect)


func _on_area_2d_area_entered(area: Area2D) -> void:
	pass # Replace with function body.



	
