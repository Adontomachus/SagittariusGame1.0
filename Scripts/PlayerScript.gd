class_name PlayerCharacter
extends CharacterBody2D

signal camera_shake(shakeDuration)

# Health bar signals
signal send_maximum_health(max_health: float)
signal send_current_health(health: float)

# Experience bar signals
signal send_maximum_xp(max_xp: float)
signal send_current_xp(xp: float)

@export var healthPoints: float:
	set(value):
		healthPoints = clampi(value, 0, maxHealthPoints)
	get:
		return healthPoints
		
var maxHealthPoints: float = 100.0

var experiencePoints: int = 0
var maxExperiencePoints: int = 60

# PLAYER MOVEMENT VARIABLES
var moveSpeed: float = 300.0
var playerDirection: Vector2
@export var projectile_damage: float = 30
var projectile := preload("res://Objects/Instances With Collision/PrototypeProjectile.tscn")
var projectileShotEffect := preload("res://Objects/Particle Effects/ShootEffect.tscn")
var upgradeEffect := preload("res://Objects/Particle Effects/LevelUpEffect.tscn")
@export var player_sprite: Sprite2D

# Shot properties
@onready var shot_point: Marker2D = $ShotPoint
@onready var shot_sound: AudioStreamPlayer = $ShotAudio


func _ready():
	# Connecting the camera shake signal
	var camera = get_tree().get_first_node_in_group("CameraControl")
	if camera_shake.is_connected(camera._shake_camera_on_shoot) == false:
		camera_shake.connect(camera._shake_camera_on_shoot)
	
	healthPoints = maxHealthPoints
	
	# Player experience bar
	send_maximum_xp.emit(maxExperiencePoints)
	send_current_xp.emit(experiencePoints)

	# Player health bar
	send_maximum_health.emit(maxHealthPoints)
	send_current_health.emit(healthPoints)
	
	
func get_input():
	playerDirection = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = velocity.lerp(playerDirection * moveSpeed, 0.15)
	
func _process(_delta):
	# SPRITE FLIPPING WHEN TURNING AROUND
	if get_global_mouse_position().x < global_position.x:
		player_sprite.flip_h = true
		# shotgun = global_position + weaponOffset
		#shotgun.flip_v = true
		pass
	else:
		player_sprite.flip_h = false
		#shotgun.flip_v = false
	#look_at(get_global_mouse_position())
	shot_point.look_at(get_global_mouse_position())
	
func _physics_process(delta):

	get_input()
	move_and_slide()
	
func _shoot_projectile(modifier: float = 1.0, color: Color = Color.WHITE):
	camera_shake.emit(0.2)
	var projectile_instance = projectile.instantiate()
	shot_sound.play()
	projectile_instance.change_damage(projectile_damage * modifier)
	projectile_instance.change_projectile_side(ProjectileCommon.ProjectileSide.Player)
	projectile_instance.change_projectile_modulation(color)
	projectile_instance.position = shot_point.get_global_position()
	projectile_instance.rotation_degrees = shot_point.rotation_degrees

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
	print("Player HP is now: ", healthPoints)
	healthPoints += modification
	if (healthPoints > maxHealthPoints): healthPoints = maxHealthPoints
	if (healthPoints <= 0):
		print("Game Over!")
		get_tree().paused = true
	send_current_health.emit(healthPoints)
	
func modify_current_xp(modification: int) -> void:
	print("Player XP is now: ", experiencePoints)
	experiencePoints += modification
	if (experiencePoints > maxExperiencePoints): 
		upgrade_player_stats()
	send_current_xp.emit(experiencePoints)

# Function for upgrading player stats upon levelling up
func upgrade_player_stats() -> void:
	# Increases health and damage by 4% and maximum XP requirement by 6%
	# Heals player for 20% max HP and resets current experience points by 0
	maxHealthPoints = maxHealthPoints * 1.04
	projectile_damage = projectile_damage * 1.04
	maxExperiencePoints = maxExperiencePoints * 1.06
	experiencePoints = 0
	healthPoints += maxHealthPoints / 5
	if (healthPoints > maxHealthPoints): healthPoints = maxHealthPoints
	# Level up effects
	var levelUpEffect = upgradeEffect.instantiate()
	levelUpEffect.position = self.get_global_position()
	get_tree().get_root().call_deferred("add_child", levelUpEffect)
	# Updates maximum health values
	send_current_xp.emit(experiencePoints)
	send_maximum_xp.emit(maxExperiencePoints)
	send_maximum_health.emit(maxHealthPoints)
	pass

	
