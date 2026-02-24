class_name PlayerCharacter
extends CharacterBody2D

signal camera_shake(shakeDuration)

var healthPoints: float:
	set(value):
		healthPoints = clampi(value, 0, maxHealthPoints)
	get:
		return healthPoints
var maxHealthPoints: float = 100

# PLAYER MOVEMENT VARIABLES
var moveSpeed: float = 300.0
var playerDirection: Vector2
var projectile_damage: float = 30.0
var projectile := preload("res://Objects/PrototypeProjectile.tscn")
var projectileShotEffect := preload("res://Objects/Particle Effects/ShootEffect.tscn")

# UI VARIABLES
@export var healthBar: ProgressBar #= $"../InterfaceElements/HUD/PlayerHealthBar"
@onready var updatedHealthBar: TextureProgressBar = $"../InterfaceElements/HUD/UI/UpdatedPlayerHealthBar"

func _ready():
	# Connecting the camera shake signal
	var camera = get_tree().get_first_node_in_group("CameraControl")
	camera_shake.connect(camera._shake_camera_on_shoot)
	
	healthPoints = maxHealthPoints	
	
func get_input():
	playerDirection = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = velocity.lerp(playerDirection * moveSpeed, 0.15)
	
func _process(delta):
	look_at(get_global_mouse_position())
		
	#HEALTH BAR SCRIPT
	updatedHealthBar.value = healthPoints
	updatedHealthBar.max_value = maxHealthPoints
	
func _physics_process(delta):
	var shotEffect = projectileShotEffect.instantiate()
	shotEffect.position = self.get_global_position()
	get_tree().get_root().call_deferred("add_child", projectileShotEffect)
	
	get_input()
	move_and_slide()
	return
	
func _shoot_projectile(modifier: float = 1.0, color: Color = Color.WHITE):
	camera_shake.emit(0.2)
	var projectile_instance = projectile.instantiate()
	projectile_instance.change_damage(projectile_damage * modifier)
	projectile_instance.change_projectile_side(ProjectileCommon.ProjectileSide.Player)
	projectile_instance.change_projectile_modulation(color)
	projectile_instance.position = self.get_global_position()
	projectile_instance.rotation_degrees = self.rotation_degrees
	get_tree().get_root().call_deferred("add_child", projectile_instance)
	print_debug("Damage: %s" % (projectile_damage * modifier))
	# PROJECTILE EFFECT, LIKE A MUZZLE FLASH OR MAGIC PARTICLES


	
func _on_enemy_collision_area_entered(area: Area2D) -> void:
	if (area.is_in_group("EnemyProjectile")):
		print("Player has collided with enemy!")

#func increment_player_health(increment: int) -> void:
#	healthPoints += increment



func modify_current_player_health(modification: int) -> void:
	healthPoints += modification
	pass # Replace with function body.
