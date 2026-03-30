class_name PlayerCharacter
extends CharacterBody2D

signal camera_shake(shakeDuration, shakeStrength)

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
# Projectile types
var projectile := preload("res://Objects/Instances With Collision/PrototypeProjectile.tscn")
# Enhanced version
var powered_projectile := preload("res://Objects/Instances With Collision/EnhancedProjectile.tscn")
var projectileShotEffect := preload("res://Objects/Particle Effects/ShootEffect.tscn")
var upgradeEffect := preload("res://Objects/Particle Effects/LevelUpEffect.tscn")
# Pulsing AoE instance for abililty
var pulse_aoe := preload("res://Objects/Instances With Collision/SplashDamage.tscn")
@export var player_sprite: Sprite2D

# Shot properties and point
@onready var shot_point: Marker2D = $ShotPoint
@onready var shot_sound: AudioStreamPlayer = $ShotAudio
@export_category("Number of perfect shots for enhanced attack")

#region This section consists of player abilities
# Amount for a charged AoE attack
@export var max_shots_for_charged: int = 8
var shots_for_charged: int = 8

# Booleans and conditions for using player abilities
@export var can_use_ability: bool
var ability_active: bool
var ability_cooldown: int
@onready var ability_aoe_node: Area2D = $AbilityAoE
@export var can_use_companion_ability: bool
@export var max_companion_ability_charge: float
var companion_ability_charge: float
#endregion

func _ready():
	# Connecting the camera shake signal
	var camera = get_tree().get_first_node_in_group("CameraControl")
	if camera_shake.is_connected(camera._shake_camera_on_shoot) == false:
		camera_shake.connect(camera._shake_camera_on_shoot)
	
	# Setting the current health from max HP value and disabling active ability on start
	ability_active = false
	if !ability_active:
		ability_aoe_node.hide()
	healthPoints = maxHealthPoints
	
	# Player experience bar
	send_maximum_xp.emit(maxExperiencePoints)
	send_current_xp.emit(experiencePoints)

	# Player health bar
	send_maximum_health.emit(maxHealthPoints)
	send_current_health.emit(healthPoints)
	
#region Movement and ability inputs
func get_input() -> void:
	playerDirection = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = velocity.lerp(playerDirection * moveSpeed, 0.15)
func get_ability_inputs() -> void:
	if Input.is_action_pressed("use_ability"):
		activate_player_ability()
	

func activate_player_ability() -> void:
	ability_active = true
	ability_aoe_node.show()
	pass
#endregion

#region Main processes
func _process(_delta):
	# Ability functions
	get_ability_inputs()
	# Sprite flipping on turnarounds
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
	
#endregion
#region SHOOTING PROJECTILE
func _shoot_projectile(modifier: float = 1.0, color: Color = Color.WHITE):
	camera_shake.emit(0.3)
	if shots_for_charged >= max_shots_for_charged:
		# Shoots the enhanced projectile and sets the beat charge to 0
		var enhanced_projectile = powered_projectile.instantiate()
		shot_sound.play()
		enhanced_projectile.change_damage((projectile_damage * modifier) * 3.2)
		enhanced_projectile.position = shot_point.get_global_position()
		enhanced_projectile.rotation_degrees = shot_point.rotation_degrees
		get_tree().get_root().call_deferred("add_child", enhanced_projectile)
		shots_for_charged = 0
	else:
		# Shoots the normal projectile
		var projectile_instance = projectile.instantiate()
		shot_sound.play()
		projectile_instance.change_damage(projectile_damage * modifier)
		projectile_instance.change_projectile_side(ProjectileCommon.ProjectileSide.Player)
		projectile_instance.change_projectile_modulation(color)
		projectile_instance.position = shot_point.get_global_position()
		projectile_instance.rotation_degrees = shot_point.rotation_degrees
		get_tree().get_root().call_deferred("add_child", projectile_instance)
	
	# PROJECTILE EFFECT, LIKE A MUZZLE FLASH OR MAGIC PARTICLES
	var shotEffect = projectileShotEffect.instantiate()
	shotEffect.position = self.get_global_position()
	get_tree().get_root().call_deferred("add_child", shotEffect)
	# PROJECTILE EFFECT, LIKE A MUZZLE FLASH OR MAGIC PARTICLES
	
	# Prints the damage value of instantiated shot for debug
	print_debug("Damage: %s" % (projectile_damage * modifier))

	# Charge up powered shot, up to 8 times
	## This function is signaled through the beat indicator
func increment_player_charge_attack() -> void:
	print("CHARGING SHOT: ", shots_for_charged)
	shots_for_charged += 1
	
#endregion

#region Checking if Sagittarrius's AoE is active or not
# This function is also connected to the global beat synchronization script
func _ability_pulse_checker() -> void:
	## AoE effect instantiates for every note. Faster tempos mean faster damage instances
	## The 'if statement' checks if the ability is active or not.
	if ability_active:
		var aoe_damage = pulse_aoe.instantiate()
		#shot_sound.play()
		aoe_damage.change_damage(projectile_damage / randf_range(1.4, 1.6))
		aoe_damage.position = shot_point.get_global_position()
		get_tree().get_root().call_deferred("add_child", aoe_damage)
		return 
#endregion

#region Player stat modifications
# Modifies current player health
func modify_current_player_health(modification: int) -> void:
	print("Player HP is now: ", healthPoints)
	healthPoints += modification
	if (healthPoints > maxHealthPoints): healthPoints = maxHealthPoints
	if (healthPoints <= 0):
		print("Game Over!")
		get_tree().paused = true
	send_current_health.emit(healthPoints)
	
# Modifies player experience points
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
#endregion
