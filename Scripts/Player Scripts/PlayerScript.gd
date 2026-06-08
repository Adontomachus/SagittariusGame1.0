class_name PlayerCharacter
extends CharacterBody2D

@export var camera : CameraControl

signal camera_shake(shakeDuration, shakeStrength)

# Health bar signals
signal send_maximum_health(max_health: float)
signal send_current_health(health: float)

# Experience bar signals
signal send_maximum_xp(max_xp: float)
signal send_current_xp(xp: float)

# Companion upgrade signal
signal companion_upgrade

@export var hit_flash: HitFlash
@export var UpgradeScreen : Control

@export var healthPoints: float:
	set(value):
		healthPoints = clampi(value, 0, maxHealthPoints)
	get:
		return healthPoints

# Exports the main game manager from the current gameplay scene		
@export var manager: GManager

#region General Player Statistics		

## Player level section and their statistics
# Main Statistics
var player_level: int = 1
var maxHealthPoints: float = 100.0
var experiencePoints: int = 0
var maxExperiencePoints: int = 60
# Levels required for an item upgrade
@export var max_levels_left_for_item_upgrade: int = 8
var levels_left_for_item_upgrade: int = 8


# PLAYER MOVEMENT VARIABLES
var moveSpeed: float
@export var maxMoveSpeed: float = 300.0
var playerDirection: Vector2
@export var projectile_damage: float = 30
#endregion

@export_category("Alternate Attacks")
@export var charge_shot: ChargeShot
@export var q_moves: QMoves

@export_category("Dash Values")
@export var dash_force: float = 1600.0
@export var dash_duration: float = 0.15
var is_dashing: bool = false
var dash_velocity: Vector2 = Vector2.ZERO

@export_category("Grenade Values")
@export var grenade_scene: PackedScene
@export var grenade_damage: float = 70.0
@export var grenade_radius: float = 120.0
@export var grenade_cooldown: float = 0.0
@export var grenade_damage_divisor_min: float = 1.15
@export var grenade_divisor_max: float = 0.9
var grenade_ready: bool = true

#region Reference object 
# Projectile types
var projectile := preload("res://Objects/Instances With Collision/PrototypeProjectile.tscn")
# Enhanced version
var powered_projectile := preload("res://Objects/Instances With Collision/EnhancedProjectile.tscn")
var projectileShotEffect := preload("res://Objects/Particle Effects/ShootEffect.tscn")
var upgradeEffect := preload("res://Objects/Particle Effects/LevelUpEffect.tscn")
# Pulsing AoE instance for abililty
var pulse_aoe := preload("res://Objects/Instances With Collision/SplashDamage.tscn")

# Shot properties and point
@export var pulse_sound_effect: AudioStreamPlayer
@onready var shot_point: Marker2D = $ShotPoint
@onready var shot_sound: AudioStreamPlayer = $ShotAudio
# Visual feedback and UI feedback for charged shot
@onready var charged_shot_particles: CPUParticles2D = $ChargedShotParticles
@export var charged_shot_ready_interface: Sprite2D
# Primary fire and its fire rate
@export_category("Player Fire Rate")
var shot_fire_rate: float
@export var max_shot_fire_rate: float = 0.1
# Secondary fire and its fire rate
var secondary_fire_rate: float
@export var max_secondary_fire_rate: float = 0.12

#endregion

#region This section consists of player abilities and a sole boolean if controllable
## Amount for a charged AoE attack and a boolean when charged
## @export var max_shots_for_charged: int = 8
## var shots_for_charged: int = 8
var can_fire_charged_shot: bool = false

## Booleans and conditions for using player abilities
@export var can_use_ability: bool
# Boolean to check if AoE ability is active
var ability_active: bool
var ability_duration: int
# Ability cooldown
@export var max_ability_cooldown: float
var ability_cooldown: float

@onready var ability_aoe_node: Area2D = $AbilityAoE

## Boolean if secondary fire is active or not (Holding right click activates while releasing deactivates it)
var secondary_fire_active: bool = false

## Properties for companion ability, which causes them to charge at enemies
@export var can_use_companion_ability: bool
@export var max_companion_ability_charge: float
var companion_ability_charge: float
@export var ability_visual_feedback: AnimationPlayer
 
## This variable determines if the player can provide inputs for the player character
## This boolean is usually set to true as long as the scene isn't paused
var can_control_unit: bool = true
#endregion

## TESTING PURPOSES
@onready var player_sprite_up_right_walking: AnimatedSprite2D = $PlayerSpriteUpRightWalking

#region Sprites section
## Sprites for the orthographic direction to face where the player's cursor is
## There are 8 directions mimicking the compass directions
@export_category("Orthographic Sprite Rotations")
@export var sprite_up: Sprite2D
@export var sprite_up_right: Sprite2D
@export var sprite_right: Sprite2D
@export var sprite_down_right: Sprite2D
@export var sprite_down: Sprite2D
@export var sprite_down_left: Sprite2D
@export var sprite_left: Sprite2D
@export var sprite_up_left: Sprite2D
#endregion

#region Companion Progression System
@export_category("Companion Progression Statistics")
@export var max_points_to_transform: float = 2000
@export var points_to_transform: float = 0

## CUTSCENE TESTING
@export var cutscene_handler: Node

func _ready():
	# Resets upgrades
	UpgradeSystemScript.reset()
	# Sets up move speed
	
	# Sets up the fire rate mechanics
	shot_fire_rate = max_shot_fire_rate
	
	# Connecting the camera shake signal
	var camera = get_tree().get_first_node_in_group("CameraControl")
	if camera_shake.is_connected(camera._shake_camera_on_shoot) == false:
		camera_shake.connect(camera._shake_camera_on_shoot)
	
	# Setting the current health from max HP value and disabling active ability on start
	ability_active = false
	healthPoints = maxHealthPoints
	
	# Hides the AoE ability effect on start since it is disabled
	ability_aoe_node.hide()
	
	# Player experience bar
	send_maximum_xp.emit(maxExperiencePoints)
	send_current_xp.emit(experiencePoints)

	# Player health bar
	send_maximum_health.emit(maxHealthPoints)
	send_current_health.emit(healthPoints)
	
#region Movement and ability inputs
func get_input() -> void:
	if can_control_unit:
		playerDirection = Input.get_vector("move_left", "move_right", "move_up", "move_down")
		velocity = velocity.lerp(playerDirection * moveSpeed, 0.15)
func get_ability_inputs() -> void:
	if can_control_unit:
		if Input.is_action_pressed("use_ability"):
			if q_moves.ability_type == QMoves.AbilityType.Q_NONE:
				return
			if can_use_ability:
				ability_cooldown = max_ability_cooldown
				activate_player_ability()
				can_use_ability = false
				ability_visual_feedback.play("AbilityActivationVisual")
		else:
			moveSpeed = maxMoveSpeed
			secondary_fire_active = false

func activate_player_ability() -> void:
	q_moves.activate()
	ability_aoe_node.show()
#endregion

#region Main processes
func _process(delta):
	# This short code increments the fire rate per second (0.3 max fire rate allows players to fire at 0.3 shots)
	shot_fire_rate += 1 * delta
	
	## Handled by new script
	##region Section for charged shot feedback
	### This section sets the "charged_shot" boolean to true if number of perfect shots reach the
	### max shot threshold. Also sets the boolean to false once the player fires the piercing shot.
	#if shots_for_charged >= 7:
		#charged_shot_particles.show()
	#else:
		#charged_shot_particles.hide()

	##endregion
	
	#region Decides if the character can be controlled by the player
	## If the game is paused, turn off all attempted inputs for player movement and attacks
	if manager.gamePaused:
		process_mode = Node.PROCESS_MODE_INHERIT
		can_control_unit = false

	else:
		process_mode = Node.PROCESS_MODE_ALWAYS
		can_control_unit = true
	
	## This changes the player's process to inherit when the game ends
	if cutscene_handler.game_is_over || cutscene_handler.game_is_won:
		process_mode = Node.PROCESS_MODE_INHERIT
		can_control_unit = false
	#endregion
	
	## Ability functions
	get_ability_inputs()
	## Decrement cooldown in delta when the AoE ability is used
	ability_cooldown -= 1 * delta
	#print ("Cooldown: ", ability_cooldown)
	
	if ability_cooldown < 0: can_use_ability = true


	
	
	## This section is for orthographic sprite rotations and animations
	#region Testing sprite orthographic rotations
	var mouse_direction = get_global_mouse_position() - global_position
	var look_angle = rad_to_deg(mouse_direction.angle())
	if look_angle > -22.5 and look_angle <= 22.5: # RIGHT
		#region Sprite listing
		sprite_up.visible = false
		sprite_up_right.visible = false
		sprite_right.visible = true
		sprite_down_right.visible = false
		sprite_down.visible =  false
		sprite_down_left.visible = false
		sprite_left.visible = false
		sprite_up_left.visible = false
		#endregion
	elif look_angle > 22.5 and look_angle <= 67.5: # DOWN RIGHT
		#region Sprite listing
		sprite_up.visible = false
		sprite_up_right.visible = false
		sprite_right.visible = false
		sprite_down_right.visible = true
		sprite_down.visible =  false
		sprite_down_left.visible = false
		sprite_left.visible = false
		sprite_up_left.visible = false
		#endregion
	elif look_angle > 67.5 and look_angle <= 112.5: # DOWN
		#region Sprite listing
		sprite_up.visible = false
		sprite_up_right.visible = false
		sprite_right.visible = false
		sprite_down_right.visible = false
		sprite_down.visible =  true
		sprite_down_left.visible = false
		sprite_left.visible = false
		sprite_up_left.visible = false
		#endregion
	elif look_angle > 112.5 and look_angle <= 157.5: # DOWN LEFT
		#region Sprite listing
		sprite_up.visible = false
		sprite_up_right.visible = false
		sprite_right.visible = false
		sprite_down_right.visible = false
		sprite_down.visible =  false
		sprite_down_left.visible = true
		sprite_left.visible = false
		sprite_up_left.visible = false
		#endregion
	elif look_angle > 157.5 or look_angle <= -157.5: # LEFT
		#region Sprite listing
		sprite_up.visible = false
		sprite_up_right.visible = false
		sprite_right.visible = false
		sprite_down_right.visible = false
		sprite_down.visible =  false
		sprite_down_left.visible = false
		sprite_left.visible = true
		sprite_up_left.visible = false
		#endregion
	elif look_angle > -157.5 and look_angle <= -112.5: # UP LEFT
		#region Sprite listing
		sprite_up.visible = false
		sprite_up_right.visible = false
		sprite_right.visible = false
		sprite_down_right.visible = false
		sprite_down.visible =  false
		sprite_down_left.visible = false
		sprite_left.visible = false
		sprite_up_left.visible = true
		#endregion
	elif look_angle > -112.5 and look_angle <= -67.5: # UP
		#region Sprite listing
		sprite_up.visible = true
		sprite_up_right.visible = false
		sprite_right.visible = false
		sprite_down_right.visible = false
		sprite_down.visible =  false
		sprite_down_left.visible = false
		sprite_left.visible = false
		sprite_up_left.visible = false
		#endregion
	elif look_angle > -67.5 and look_angle <= -22.5: # UP RIGHT
		#region Sprite listing
		sprite_up.visible = false
		sprite_up_right.visible = true
		sprite_right.visible = false
		sprite_down_right.visible = false
		sprite_down.visible =  false
		sprite_down_left.visible = false
		sprite_left.visible = false
		sprite_up_left.visible = false
		#endregion
	#endregion
	shot_point.look_at(get_global_mouse_position())
	
	
func _physics_process(delta):
	if is_dashing:
		velocity = dash_velocity      
		move_and_slide()
		return       
	get_input()
	move_and_slide()
	
#endregion

#region SHOOTING PROJECTILE
func _shoot_projectile(modifier: float = 1.0, color: Color = Color.WHITE):
	camera.add_trauma(0.5)   
	if shot_fire_rate > max_shot_fire_rate:
		if charge_shot.consume(modifier):
			# Charged shot fired — still need sound and effect
			shot_sound.play()
		else:
			# Normal shot
			var projectile_instance = projectile.instantiate()
			shot_sound.play()
			projectile_instance.change_damage(projectile_damage * modifier)
			projectile_instance.change_projectile_side(ProjectileCommon.ProjectileSide.Player)
			projectile_instance.change_projectile_modulation(color)
			projectile_instance.position = shot_point.get_global_position()
			projectile_instance.rotation_degrees = shot_point.rotation_degrees
			get_tree().get_root().call_deferred("add_child", projectile_instance)

		# Shared between both paths
		var shotEffect = projectileShotEffect.instantiate()
		shotEffect.position = self.get_global_position()
		get_tree().get_root().call_deferred("add_child", shotEffect)
		shot_fire_rate = 0    # was missing on the charged path
		print_debug("Damage: %s" % (projectile_damage * modifier))


	# Charge up powered shot, up to 8 times
	## This function is signaled through the beat indicator
func increment_player_charge_attack() -> void:
	# print("CHARGING SHOT: ", shots_for_charged)
	charge_shot.increment()
	
#endregion

###Q Move 
#func _ability_pulse() -> void:
	#if not q_moves.ability_active:    
		#return
	#q_moves.ability_duration -= 1
	#var aoe_damage = pulse_aoe.instantiate()
	#pulse_sound_effect.play()
	#aoe_damage.change_damage(projectile_damage / randf_range(q_moves.damage_divisor_min, q_moves.damage_divisor_max))
	#aoe_damage.position = shot_point.get_global_position()
	#get_tree().get_root().call_deferred("add_child", aoe_damage)
	#if q_moves.ability_duration <= 0:
		#ability_aoe_node.hide()
		#q_moves.ability_active = false

## SECONDARY FIRE RATE FUNCTION
func _shoot_secondary() -> void:
	camera.add_trauma(0.5)   
	var projectile_instance = projectile.instantiate()
	shot_sound.play()
	projectile_instance.change_damage(projectile_damage / 1.75)
	projectile_instance.change_projectile_side(ProjectileCommon.ProjectileSide.Player)
	projectile_instance.position = shot_point.get_global_position()
	projectile_instance.rotation_degrees = shot_point.rotation_degrees
	get_tree().get_root().call_deferred("add_child", projectile_instance)
		
	# PROJECTILE EFFECT, LIKE A MUZZLE FLASH OR MAGIC PARTICLES
	var shotEffect = projectileShotEffect.instantiate()
	shotEffect.position = self.get_global_position()
	get_tree().get_root().call_deferred("add_child", shotEffect)
	# PROJECTILE EFFECT, LIKE A MUZZLE FLASH OR MAGIC PARTICLES
		
	# Prints the damage value of instantiated shot for debug
	print_debug("Damage: %s" % (projectile_damage / 1.75))
	pass

#region Sprite rotation functions
func update_sprite_rotations(cursor_direction):
	var mouse_angle = rad_to_deg(cursor_direction)
	

	pass
#endregion

##region Checking if Sagittarrius's AoE is active or not
### This function is also connected to the global beat synchronization script
#func _ability_pulse_checker() -> void:
	#### AoE effect instantiates for every note. Faster tempos mean faster damage instances
	#### The 'if statement' checks if the ability is active or not.
	#if ability_active:
		#ability_duration -= 1
		#var aoe_damage = pulse_aoe.instantiate()
		#pulse_sound_effect.play()
		###shot_sound.play()
		#aoe_damage.change_damage(projectile_damage / randf_range(1.4, 1.6))
		#aoe_damage.position = shot_point.get_global_position()
		#get_tree().get_root().call_deferred("add_child", aoe_damage)
		#if ability_duration <= 0:
			#ability_aoe_node.hide()
			#ability_active = false
		##eturn 
##endregion

#region Player stat modifications
# Modifies current player health
func modify_current_player_health(modification: int) -> void:
	print("Player HP is now: ", healthPoints)
	healthPoints += modification
	if (healthPoints > maxHealthPoints): healthPoints = maxHealthPoints
	
	# Camera shake when hit
	# When damaged
	if modification < 0:
		camera.add_trauma(0.8)   
		if hit_flash:
			hit_flash.flash()
			print("Should flash")
		print("Got hit!")
	
	if (healthPoints <= 0):
		camera.add_trauma(1)
		print("Game Over!")
		can_control_unit = false
		cutscene_handler.game_is_over = true
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
	# Increases health and damage by 4% and maximum XP requirement by 6% and increment player level by 1
	# Heals player for 20% max HP and resets current experience points by 0
	player_level += 1
	PointSystemScript.player_levels = player_level
	maxHealthPoints = maxHealthPoints * 1.03
	projectile_damage = projectile_damage * 1.06
	maxExperiencePoints = maxExperiencePoints * 1.05
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
	companion_upgrade.emit()
	
	if UpgradeSystemScript.should_show_upgrades(player_level):
		UpgradeScreen.visible = true
		UpgradeScreen.show_upgrades()
	pass
#endregion
	
	
#region Secondary Fire
func _dash() -> void:
	## Your dash logic here — example:
	var dash_direction := Vector2(
		Input.get_axis("move_left", "move_right"),
		Input.get_axis("move_up", "move_down")
	).normalized()
	## If no input, dash in the direction of the mouse
	if dash_direction == Vector2.ZERO:
		dash_direction = (get_global_mouse_position() - global_position).normalized()
		
	velocity += dash_direction * dash_force   
	## Timer releases the dash after dash_duration seconds
	await get_tree().create_timer(dash_duration).timeout
	is_dashing = false
	dash_velocity = Vector2.ZERO

func _grenade() -> void:
	if not grenade_ready:
		print("Grenade on cooldown")
		return

	var grenade = grenade_scene.instantiate()
	get_tree().get_root().call_deferred("add_child", grenade)
	
	grenade.explosion_damage = grenade_damage / (randf_range(grenade_damage_divisor_min, grenade_divisor_max))
	grenade.explosion_radius = grenade_radius
	## Wait one frame so the node is in the tree before calling launch()
	await get_tree().process_frame
	grenade.launch(global_position, get_global_mouse_position())

	## Cooldown
	grenade_ready = false
	await get_tree().create_timer(grenade_cooldown).timeout
	grenade_ready = true
#endregion
