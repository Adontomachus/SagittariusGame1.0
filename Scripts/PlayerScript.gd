extends CharacterBody2D

var healthPoints
var maxHealthPoints = 100

# PLAYER MOVEMENT VARIABLES
var moveSpeed = 300
var playerDirection
var projectile = preload("res://Objects/PlayerProjectile.tscn")

func _ready():
	
	pass
	
	
func get_input():
	playerDirection = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = velocity.lerp(playerDirection * moveSpeed, 0.15)
	
func _process(delta):
	look_at(get_global_mouse_position())
	pass
	
func _physics_process(delta):
	get_input()
	move_and_slide()
	return
	
func _shoot_projectile():
	var projectile_instance = projectile.instantiate()
	projectile_instance.position = self.get_global_position()
	projectile_instance.rotation_degrees = self.rotation_degrees
	get_tree().get_root().call_deferred("add_child", projectile_instance)
