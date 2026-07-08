class_name PlayerCharacter
extends CharacterBody2D

@export_category("Chain Combo Audio")
@export var comet_sfx: AudioStreamPlayer
@export var cadence_sfx: AudioStreamPlayer
@export var echo_nova_sfx: AudioStreamPlayer

@export var chain_tier_ui: ChainTierUI
@export var chain_border_glow: ChainBorderGlow
@export var chain_aura: ChainAura

@export var camera : CameraControl
@onready var hit_sound: AudioStreamPlayer2D = $PlayerHitSound



signal camera_shake(shakeDuration, shakeStrength)

# Health bar signals
signal send_maximum_health(max_health: float)
signal send_current_health(health: float)

# Experience bar signals
signal send_maximum_xp(max_xp: float)
signal send_current_xp(xp: float)

# Companion upgrade signal
signal companion_upgrade

# Level up visual signal
signal visual_upgrade_effects

@export var hit_flash: HitFlash
@export var UpgradeScreen : Control
@export var beatSquash : BeatSquashStretch

@export var healthPoints: float:
	set(value):
		healthPoints = clampi(value, 0, maxHealthPoints)
	get:
		return healthPoints

# Exports the main game manager from the current gameplay scene		
@export var manager: GManager

# Refactored the sprite facing sprite
@onready var player_sprite: AnimatedSprite2D = $VisualRoot/PlayerSprite
enum FacingDirection {
	UP,
	UP_RIGHT,
	RIGHT,
	DOWN_RIGHT,
	DOWN,
	DOWN_LEFT,
	LEFT,
	UP_LEFT
}

@export_category("Projectile Spawn Offsets")
@export var offset_right: Vector2 = Vector2(20, 0)
@export var offset_down_right: Vector2 = Vector2(14, 14)
@export var offset_down: Vector2 = Vector2(0, 20)
@export var offset_down_left: Vector2 = Vector2(-14, 14)
@export var offset_left: Vector2 = Vector2(-20, 0)
@export var offset_up_left: Vector2 = Vector2(-14, -14)
@export var offset_up: Vector2 = Vector2(0, -20)
@export var offset_up_right: Vector2 = Vector2(14, -14)

var current_facing: FacingDirection = FacingDirection.DOWN

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
@export var maxMoveSpeed: float = 350.0
var playerDirection: Vector2
@export var projectile_damage: float = 30
#endregion

var kapre_smoke_effect := preload("res://Objects/Particle Effects/KapreSmokeEffect.tscn")

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
@export var grenade_damage: float = 105.0
@export var grenade_radius: float = 120.0
@export var grenade_cooldown: float = 0.0
@export var grenade_damage_divisor_min: float = 1.08
@export var grenade_divisor_max: float = 0.92
var grenade_ready: bool = true

#New upgrade things
#region AGIMAT PASSIVES
var agimat_echo: bool = false
var balete_heart: bool = false
var tikbalang_step: bool = false
var harana_flame: bool = false
var anito_blessing: bool = false
var kundiman_shield: bool = false
var kundiman_shield_used: bool = false
var sarimanok_feather: bool = false
var diwata_veil: bool = false
var kapre_smoke: bool = false
var nuno_root: bool = false
#endregion

# For agimats
#region EXTRA AGIMAT VARIABLES
var diwata_invulnerable: bool = false
var kapre_shot_counter: int = 0
var _diwata_timer: float = 0.0
var _nuno_root_timer: float = 0.0
var _nuno_regen_tick: float = 0.0
const NUNO_STILL_THRESHOLD: float = 10.0   ## speed below this counts as standing still
const NUNO_REGEN_INTERVAL: float = 1.0    ## regen tick every second
const NUNO_REGEN_AMOUNT: float = 3.0      ## HP per tick
#endregion

# For perfect chain
#region PERFECT CHAIN SYSTEM
var perfect_chain: int = 0

var cadence_mode: bool = false
var cadence_charge_multiplier: float = 1.0

var projectile_size_multiplier: float = 1.0
var projectile_speed_multiplier: float = 1.0
var projectile_damage_multiplier: float = 1.0
#endregion

#region TIKBALANG STEP
var tikbalang_speed_timer: float = 0.0
var tikbalang_speed_bonus: float = 1.5
#endregion

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
	moveSpeed = maxMoveSpeed
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
			#moveSpeed = maxMoveSpeed
			secondary_fire_active = false

func activate_player_ability() -> void:
	q_moves.activate()
	ability_aoe_node.show()
#endregion

#region Main processes
func _process(delta):
	# This short code increments the fire rate per second (0.3 max fire rate allows players to fire at 0.3 shots)
	shot_fire_rate += 1 * delta

	## Tikbalang Step timer decay
	if tikbalang_step and tikbalang_speed_timer > 0:
		tikbalang_speed_timer -= delta
		moveSpeed = maxMoveSpeed * tikbalang_speed_bonus
	elif tikbalang_step and tikbalang_speed_timer <= 0:
		moveSpeed = maxMoveSpeed

	## Nuno Root — regen health while standing still
	if nuno_root:
		_process_nuno_root(delta)

	## Diwata Veil — invulnerability timer
	if diwata_invulnerable:
		_diwata_timer -= delta
		if _diwata_timer <= 0:
			diwata_invulnerable = false

	
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
	_update_facing_direction()
	_update_walk_animation()
	shot_point.rotation_degrees = _get_facing_rotation()

func _update_facing_direction():
	var mouse_direction = get_global_mouse_position() - global_position
	var look_angle = rad_to_deg(mouse_direction.angle())

	if look_angle > -22.5 and look_angle <= 22.5:
		current_facing = FacingDirection.RIGHT
	elif look_angle > 22.5 and look_angle <= 67.5:
		current_facing = FacingDirection.DOWN_RIGHT
	elif look_angle > 67.5 and look_angle <= 112.5:
		current_facing = FacingDirection.DOWN
	elif look_angle > 112.5 and look_angle <= 157.5:
		current_facing = FacingDirection.DOWN_LEFT
	elif look_angle > 157.5 or look_angle <= -157.5:
		current_facing = FacingDirection.LEFT
	elif look_angle > -157.5 and look_angle <= -112.5:
		current_facing = FacingDirection.UP_LEFT
	elif look_angle > -112.5 and look_angle <= -67.5:
		current_facing = FacingDirection.UP
	elif look_angle > -67.5 and look_angle <= -22.5:
		current_facing = FacingDirection.UP_RIGHT

func _get_direction_name() -> String:
	match current_facing:
		FacingDirection.UP: return "up"
		FacingDirection.UP_RIGHT: return "up_right"
		FacingDirection.RIGHT: return "right"
		FacingDirection.DOWN_RIGHT: return "down_right"
		FacingDirection.DOWN: return "down"
		FacingDirection.DOWN_LEFT: return "down_left"
		FacingDirection.LEFT: return "left"
		FacingDirection.UP_LEFT: return "up_left"

	return "down"

var is_locked_in_action := false

var _previous_active_sprite: AnimatedSprite2D = null
# Updates walk animation
func _get_movement_direction_name() -> String:
	## Use velocity to determine walk direction
	var vel := velocity.normalized()
	## Only calculate if actually moving
	if vel.length() < 0.1:
		return _get_direction_name()  ## fall back to facing direction when idle
	var move_angle := rad_to_deg(vel.angle())
	if move_angle > -22.5 and move_angle <= 22.5:
		return "right"
	elif move_angle > 22.5 and move_angle <= 67.5:
		return "down_right"
	elif move_angle > 67.5 and move_angle <= 112.5:
		return "down"
	elif move_angle > 112.5 and move_angle <= 157.5:
		return "down_left"
	elif move_angle > 157.5 or move_angle <= -157.5:
		return "left"
	elif move_angle > -157.5 and move_angle <= -112.5:
		return "up_left"
	elif move_angle > -112.5 and move_angle <= -67.5:
		return "up"
	elif move_angle > -67.5 and move_angle <= -22.5:
		return "up_right"
	return "down"


func _update_walk_animation() -> void:
	if is_locked_in_action:
		return
	var is_moving := velocity.length() > 10.0
	var action := "walk" if is_moving else "idle"
	
	## Walk uses movement direction, idle uses facing direction
	var dir_name := _get_movement_direction_name() if is_moving else _get_direction_name()
	var animation_name := "%s_%s" % [action, dir_name]
	
	if player_sprite.animation != animation_name:
		player_sprite.play(animation_name)
	
func play_action(action: String):
	if is_locked_in_action:
		return
	
	is_locked_in_action = true
	var animation_name := "%s_%s" % [action, _get_direction_name()]
	player_sprite.play(animation_name)

	await player_sprite.animation_finished
	is_locked_in_action = false
	
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
	play_action("shoot")
	
	if shot_fire_rate < max_shot_fire_rate:
		return
	shot_fire_rate = 0
	var spawn_pos := global_position + _get_facing_offset()
	var spawn_rotation := _get_projectile_rotation_from_spawn(spawn_pos)
	## Kapre Smoke counter
	var this_shot_is_kapre := false
	if kapre_smoke:
		kapre_shot_counter += 1
		if kapre_shot_counter >= 8:
			kapre_shot_counter = 0
			this_shot_is_kapre = true

	if charge_shot.consume(modifier):
		shot_sound.play()
	else:
		var projectile_instance = projectile.instantiate()
		shot_sound.play()

		var final_damage := projectile_damage * modifier * projectile_damage_multiplier
		projectile_instance.change_damage(int(final_damage))
		projectile_instance.change_projectile_side(ProjectileCommon.ProjectileSide.Player)
		projectile_instance.change_projectile_modulation(color)
		projectile_instance.position = spawn_pos
		projectile_instance.rotation_degrees = spawn_rotation
		projectile_instance.hit_combo_value = _get_combo_value_for_shot(modifier)
		if this_shot_is_kapre:
			projectile_instance.is_kapre_shot = true
			projectile_instance.kapre_damage = final_damage * 1.5
		if projectile_size_multiplier != 1.0:
			projectile_instance.set_projectile_size(projectile_size_multiplier)

		if projectile_speed_multiplier != 1.0:
			projectile_instance.projectileVelocity *= projectile_speed_multiplier

		projectile_instance.get_node("OrbitingParticles").set_effect_color(color)
		get_tree().get_root().call_deferred("add_child", projectile_instance)

		if sarimanok_feather:
			_shoot_sarimanok_spread(modifier, color)
		if agimat_echo and modifier >= 1.45:
			_shoot_echo.call_deferred(modifier, color)

	var shotEffect = projectileShotEffect.instantiate()
	var was_perfect := modifier >= 1.45
	shotEffect.set_effect_color(color, was_perfect)
	shotEffect.position = spawn_pos
	get_tree().get_root().call_deferred("add_child", shotEffect)
	print_debug("Damage: %s" % (projectile_damage * modifier * projectile_damage_multiplier))

## Offset distance from player center — adjust to match your sprite size
@export var projectile_spawn_offset: float = 20.0

func _on_perfect_hit() -> void:
	perfect_chain += 1

	## Tikbalang Step
	if tikbalang_step:
		tikbalang_speed_timer = 1.25

	## Perfect Chain x4
	if perfect_chain >= 4:
		_enable_comet_projectile()

	## Perfect Chain x8
	if perfect_chain >= 8 and !cadence_mode:
		_enter_cadence_mode()

	## Perfect Chain x16
	if perfect_chain >= 16:
		_trigger_echo_nova()

func _on_missed_beat():
	if kundiman_shield and not kundiman_shield_used:
		kundiman_shield_used = true
		print("Kundiman Shield protected combo!")
		return
	if charge_shot:
		charge_shot.shots_for_charged = 0
		charge_shot._update_feedback()
	perfect_chain = 0
	cadence_mode = false
	cadence_charge_multiplier = 1.0
	projectile_size_multiplier = 1.0
	projectile_speed_multiplier = 1.0
	projectile_damage_multiplier = 1.0
	if player_sprite:
		player_sprite.modulate = Color.WHITE
	_clear_chain_visuals()
	
func _update_chain_visuals() -> void:
	var tier := 0
	var color := Color.WHITE
	if perfect_chain >= 16:
		tier = 16
		color = Color(1.0, 0.3, 0.9)
	elif perfect_chain >= 8:
		tier = 8
		color = Color(0.5, 0.9, 1.0)
	elif perfect_chain >= 4:
		tier = 4
		color = Color(1.0, 0.8, 0.4)

	if chain_tier_ui:
		chain_tier_ui.update_tier(perfect_chain)
	if chain_border_glow:
		chain_border_glow.set_tier(tier, color)
	if chain_aura:
		chain_aura.set_tier(tier, color)


func _clear_chain_visuals() -> void:
	if chain_tier_ui:
		chain_tier_ui.reset_tier()
	if chain_border_glow:
		chain_border_glow.clear()
	if chain_aura:
		chain_aura.set_tier(0, Color.WHITE)

func _enable_comet_projectile() -> void:
	comet_sfx.play()
	projectile_size_multiplier = 1.5
	projectile_speed_multiplier = 1.25
	projectile_damage_multiplier = 1.35
	print("Comet Form activated!")
	if player_sprite:
		player_sprite.modulate = Color(1.2, 1.0, 0.6, 1.0)
	_update_chain_visuals()


func _enter_cadence_mode() -> void:
	cadence_sfx.play()
	cadence_mode = true
	cadence_charge_multiplier = 2.0
	print("Cadence Mode activated!")
	if player_sprite:
		player_sprite.modulate = Color(0.6, 1.0, 1.4, 1.0)
	_update_chain_visuals()


func _trigger_echo_nova() -> void:
	echo_nova_sfx.play()
	print("Echo Nova!")

	## Only damage enemies within nova radius
	var nova_radius := 400.0
	var enemies := get_tree().get_nodes_in_group("GeneralEnemyInstance")
	for enemy in enemies:
		if not is_instance_valid(enemy):
			continue
		if enemy.has_method("modify_health"):
			var dist := global_position.distance_to(enemy.global_position)
			if dist <= nova_radius:
				enemy.modify_health(-int(projectile_damage * 2.0))

	## Spawn AoE damage zone at player
	var nova := pulse_aoe.instantiate()
	nova.change_damage(int(projectile_damage * 2.0))
	nova.position = global_position
	nova.scale = Vector2(4.0, 4.0)
	get_tree().get_root().call_deferred("add_child", nova)

	## Big camera trauma
	camera.add_trauma(1.5)

	## Full screen flash
	if hit_flash:
		hit_flash.nova_flash()
	var nova_ring = load("res://Objects/Particle Effects/NovaRing.tscn").instantiate()
	nova_ring.position = global_position
	nova_ring.max_radius = 1000.0
	get_tree().get_root().call_deferred("add_child", nova_ring)
	var companions := get_tree().get_nodes_in_group("Companion1") + \
					  get_tree().get_nodes_in_group("Companion2")
	for companion in companions:
		if is_instance_valid(companion) and companion.visible:
			companion.on_echo_nova()
	## Reset chain
	perfect_chain = 0
	cadence_mode = false
	cadence_charge_multiplier = 1.0
	projectile_size_multiplier = 1.0
	projectile_speed_multiplier = 1.0
	projectile_damage_multiplier = 1.0
	if player_sprite:
		player_sprite.modulate = Color.WHITE
	_clear_chain_visuals()

func _get_facing_offset() -> Vector2:
	match current_facing:
		FacingDirection.RIGHT:      return offset_right
		FacingDirection.DOWN_RIGHT: return offset_down_right
		FacingDirection.DOWN:       return offset_down
		FacingDirection.DOWN_LEFT:  return offset_down_left
		FacingDirection.LEFT:       return offset_left
		FacingDirection.UP_LEFT:    return offset_up_left
		FacingDirection.UP:         return offset_up
		FacingDirection.UP_RIGHT:   return offset_up_right
	return Vector2.ZERO

func _get_projectile_rotation_from_spawn(spawn_pos: Vector2) -> float:
	var mouse_pos := get_global_mouse_position()
	var direction := mouse_pos - spawn_pos
	return rad_to_deg(direction.angle())

func _get_facing_rotation() -> float:
	match current_facing:
		FacingDirection.RIGHT:      return 0.0
		FacingDirection.DOWN_RIGHT: return 45.0
		FacingDirection.DOWN:       return 90.0
		FacingDirection.DOWN_LEFT:  return 135.0
		FacingDirection.LEFT:       return 180.0
		FacingDirection.UP_LEFT:    return 225.0
		FacingDirection.UP:         return 270.0
		FacingDirection.UP_RIGHT:   return 315.0
	return 0.0
	
func _get_projectile_rotation() -> float:
	## Rotate projectile toward mouse regardless of spawn offset
	var mouse_dir := get_global_mouse_position() - global_position
	return rad_to_deg(mouse_dir.angle())



	# Charge up powered shot, up to 8 times
	## This function is signaled through the beat indicator
func increment_player_charge_attack() -> void:
	# print("CHARGING SHOT: ", shots_for_charged)
	charge_shot.increment()
	
#endregion

## For combo to only applying onhit
func _get_combo_value_for_shot(modifier: float) -> float:
	if modifier >= 1.45:
		return 40.0    
	elif modifier >= 1.0:
		return 15.0    
	elif modifier >= 0.8:
		return 5.0     
	return 0.0         

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
	if modification < 0 and diwata_invulnerable:
		print("Diwata Veil blocked damage!")
		return
		
	print("Player HP is now: ", healthPoints)
	healthPoints += modification
	if (healthPoints > maxHealthPoints): healthPoints = maxHealthPoints
	
	# Camera shake when hit
	# When damaged
	if modification < 0:
		camera.add_trauma(0.8)   
		if hit_flash:
			hit_flash.flash()
		hit_sound.play()
	#subtracts combo when damaged
		var combo := get_tree().get_first_node_in_group("ComboManager")
		if combo:
			combo._subtract_combo_level()
	
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
	maxHealthPoints = maxHealthPoints * 1.04
	projectile_damage = projectile_damage * 1.06
	grenade_damage = grenade_damage * 1.05
	maxExperiencePoints = maxExperiencePoints * 1.04
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
		UpgradeScreen.show_upgrades(self)
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

#region Agimats Implementation
## Nuno Root — regen while still
func _process_nuno_root(delta: float) -> void:
	if velocity.length() < NUNO_STILL_THRESHOLD:
		_nuno_root_timer += delta
		if _nuno_root_timer >= NUNO_REGEN_INTERVAL:
			_nuno_root_timer = 0.0
			modify_current_player_health(int(NUNO_REGEN_AMOUNT))
	else:
		_nuno_root_timer = 0.0


## Diwata Veil — called when player takes damage
func _trigger_diwata_veil() -> void:
	diwata_invulnerable = true
	_diwata_timer = 1.0


## Sarimanok Feather — fires spread projectiles
func _shoot_sarimanok_spread(modifier: float, color: Color) -> void:
	var spread_angles := [-18.0, 18.0]  ## left and right spread
	for angle_offset in spread_angles:
		var spread_projectile = projectile.instantiate()
		var spawn_pos := global_position + _get_facing_offset()
		spread_projectile.change_damage(projectile_damage * modifier * 0.6)
		spread_projectile.change_projectile_side(ProjectileCommon.ProjectileSide.Player)
		spread_projectile.change_projectile_modulation(color)
		spread_projectile.position = spawn_pos
		spread_projectile.rotation_degrees = _get_projectile_rotation_from_spawn(spawn_pos) + angle_offset
		spread_projectile.hit_combo_value = 0.0
		get_tree().get_root().call_deferred("add_child", spread_projectile)


## Kapre Smoke — explosion projectile
func _shoot_kapre_explosion(modifier: float, color: Color) -> void:
	var spawn_pos := global_position + _get_facing_offset()
	var spawn_rotation := _get_projectile_rotation_from_spawn(spawn_pos)

	## Damage AoE
	var aoe = pulse_aoe.instantiate()
	aoe.change_damage(int(projectile_damage * modifier * 1.5))
	aoe.position = spawn_pos
	get_tree().get_root().call_deferred("add_child", aoe)

	var smoke = kapre_smoke_effect.instantiate()
	smoke.position = spawn_pos
	get_tree().get_root().call_deferred("add_child", smoke)

	camera.add_trauma(0.4)


## Harana Flame — burn trail DOT
func _apply_harana_flame(enemy: Node) -> void:
	if not enemy.has_method("modify_health"):
		return
	## Tick 3 times over 1.5 seconds
	_harana_burn_coroutine(enemy)


func _harana_burn_coroutine(enemy: Node) -> void:
	for i in range(3):
		await get_tree().create_timer(0.5).timeout
		if is_instance_valid(enemy):
			enemy.modify_health(-int(projectile_damage * 0.2))


## Agimat Echo — repeat shot at 50%
func _shoot_echo(modifier: float, color: Color) -> void:
	await get_tree().create_timer(0.15).timeout  ## slight delay for visual separation
	if not is_instance_valid(self):
		return
	var spawn_pos := global_position + _get_facing_offset()
	var echo_proj = projectile.instantiate()
	echo_proj.change_damage(projectile_damage * modifier * 0.5)
	echo_proj.change_projectile_side(ProjectileCommon.ProjectileSide.Player)
	echo_proj.change_projectile_modulation(color.darkened(0.3))
	echo_proj.position = spawn_pos
	echo_proj.rotation_degrees = _get_projectile_rotation_from_spawn(spawn_pos)
	echo_proj.hit_combo_value = 0.0
	get_tree().get_root().call_deferred("add_child", echo_proj)
	#endregion
