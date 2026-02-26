class_name PlayerCharacter
extends CharacterBody2D

signal camera_shake(shakeDuration)

signal send_maximum_health(max_health: float)
signal send_current_health(health: float)

var healthPoints: float:
	set(value):
		healthPoints = clampi(value, 0, maxHealthPoints)
	get:
		return healthPoints
var maxHealthPoints: float = 100.0

# PLAYER MOVEMENT VARIABLES
var moveSpeed: float = 300.0
var playerDirection: Vector2
var projectile_damage: float = 30.0
var projectile := preload("res://Objects/PrototypeProjectile.tscn")
var projectileShotEffect := preload("res://Objects/Particle Effects/ShootEffect.tscn")

func _ready():
	# Connecting the camera shake signal
	var camera = get_tree().get_first_node_in_group("CameraControl")
	if camera_shake.is_connected(camera._shake_camera_on_shoot) == false:
		camera_shake.connect(camera._shake_camera_on_shoot)
	
	healthPoints = maxHealthPoints
	
	send_maximum_health.emit(maxHealthPoints)
	send_current_health.emit(healthPoints)
	
func get_input():
	playerDirection = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = velocity.lerp(playerDirection * moveSpeed, 0.15)
	
func _process(delta):
	look_at(get_global_mouse_position())
	
func _physics_process(delta):
	get_input()
	move_and_slide()
	
func _shoot_projectile(modifier: float = 1.0, color: Color = Color.WHITE):
	camera_shake.emit(0.2)
	var projectile_instance = projectile.instantiate()
	projectile_instance.change_damage(projectile_damage * modifier)
	projectile_instance.change_projectile_side(ProjectileCommon.ProjectileSide.Player)
	projectile_instance.change_projectile_modulation(color)
	projectile_instance.position = self.get_global_position()
	projectile_instance.rotation_degrees = self.rotation_degrees

	var shotEffect = projectileShotEffect.instantiate()
	shotEffect.position = self.get_global_position()

	
	get_tree().get_root().call_deferred("add_child", projectile_instance)
	get_tree().get_root().call_deferred("add_child", shotEffect)

	print_debug("Damage: %s" % (projectile_damage * modifier))
	# PROJECTILE EFFECT, LIKE A MUZZLE FLASH OR MAGIC PARTICLES


	
func _on_enemy_collision_area_entered(area: Area2D) -> void:
	if (area.is_in_group("EnemyProjectile")):
		print("Player has collided with enemy!")

#func increment_player_health(increment: int) -> void:
#	healthPoints += increment



func modify_current_player_health(modification: int) -> void:
	healthPoints += modification
	send_current_health.emit(healthPoints)
