class_name PlayerCharacter
extends CharacterBody2D

@export_category("Chain Combo Audio")
@export var comet_sfx: AudioStreamPlayer
@export var cadence_sfx: AudioStreamPlayer
@export var echo_nova_sfx: AudioStreamPlayer

@export var chain_tier_ui: ChainTierUI
@export var chain_border_glow: ChainBorderGlow
@export var chain_aura: ChainAura

@export var camera: CameraControl
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
@export var UpgradeScreen: Control
@export var beatSquash: BeatSquashStretch

@export var healthPoints: float:
	set(value):
		# FIX: use clampf instead of clampi for float values
		healthPoints = clampf(value, 0.0, maxHealthPoints)
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
var player_level: int = 1
var maxHealthPoints: float = 100.0
var experiencePoints: int = 0
var maxExperiencePoints: int = 60
@export var max_levels_left_for_item_upgrade: int = 8
var levels_left_for_item_upgrade: int = 8

# PLAYER MOVEMENT VARIABLES
var moveSpeed: float
@export var maxMoveSpeed: float = 350.0
var playerDirection: Vector2
@export var projectile_damage: float = 30.0
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

#region EXTRA AGIMAT VARIABLES
var diwata_invulnerable: bool = false
var kapre_shot_counter: int = 0
var _diwata_timer: float = 0.0
var _nuno_root_timer: float = 0.0
var _nuno_regen_tick: float = 0.0
const NUNO_STILL_THRESHOLD: float = 10.0
const NUNO_REGEN_INTERVAL: float = 1.0
const NUNO_REGEN_AMOUNT: float = 3.0
#endregion

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
var projectile := preload("res://Objects/Instances With Collision/PrototypeProjectile.tscn")
var powered_projectile := preload("res://Objects/Instances With Collision/EnhancedProjectile.tscn")
var projectileShotEffect := preload("res://Objects/Particle Effects/ShootEffect.tscn")
var upgradeEffect := preload("res://Objects/Particle Effects/LevelUpEffect.tscn")
var pulse_aoe := preload("res://Objects/Instances With Collision/SplashDamage.tscn")
const NOVA_RING_SCENE := preload("res://Objects/Particle Effects/NovaRing.tscn")

# ProjectilePool
var prototype_scene := preload("res://Objects/Instances With Collision/PrototypeProjectile.tscn")
var prototype_pool := ProjectilePool.new()

@export var pulse_sound_effect: AudioStreamPlayer
@onready var shot_point: Marker2D = $ShotPoint
@onready var shot_sound: AudioStreamPlayer = $ShotAudio
@onready var charged_shot_particles: CPUParticles2D = $ChargedShotParticles
@export var charged_shot_ready_interface: Sprite2D

@export_category("Player Fire Rate")
var shot_fire_rate: float
@export var max_shot_fire_rate: float = 0.1
var secondary_fire_rate: float
@export var max_secondary_fire_rate: float = 0.12
#endregion

#region Player abilities
var can_fire_charged_shot: bool = false
@export var can_use_ability: bool
var ability_active: bool
var ability_duration: int
@export var max_ability_cooldown: float
var ability_cooldown: float
@onready var ability_aoe_node: Area2D = $AbilityAoE
var secondary_fire_active: bool = false
@export var can_use_companion_ability: bool
@export var max_companion_ability_charge: float
var companion_ability_charge: float
@export var ability_visual_feedback: AnimationPlayer
var can_control_unit: bool = true
#endregion

## TESTING PURPOSES
@onready var player_sprite_up_right_walking: AnimatedSprite2D = $PlayerSpriteUpRightWalking

#region Companion Progression System
@export_category("Companion Progression Statistics")
@export var max_points_to_transform: float = 2000.0
@export var points_to_transform: float = 0.0

## CUTSCENE TESTING
@export var cutscene_handler: Node
#endregion

var world_parent: Node2D

#region Burn System (replaces await create_timer coroutines)
var _burn_timer: Timer
var _active_burns: Array[Dictionary]
#endregion

func _ready():
	UpgradeSystemScript.reset()
	moveSpeed = maxMoveSpeed
	shot_fire_rate = max_shot_fire_rate

	var cam = get_tree().get_first_node_in_group("CameraControl")
	if camera_shake.is_connected(cam._shake_camera_on_shoot) == false:
		camera_shake.connect(cam._shake_camera_on_shoot)

	ability_active = false
	healthPoints = maxHealthPoints
	ability_aoe_node.hide()

	send_maximum_xp.emit(maxExperiencePoints)
	send_current_xp.emit(experiencePoints)
	send_maximum_health.emit(maxHealthPoints)
	send_current_health.emit(healthPoints)

	world_parent = get_tree().current_scene.get_node_or_null(
		"GameLevelNode/Stage1/EnemyNavRegion/Map Objects/World"
	)
	
	# Projectile Pooling
	add_child(prototype_pool)
	prototype_pool.setup(prototype_scene, 50, world_parent)

	# Setup burn timer (replaces await get_tree().create_timer spam)
	_burn_timer = Timer.new()
	_burn_timer.wait_time = 0.5
	_burn_timer.one_shot = false
	_burn_timer.timeout.connect(_on_burn_tick)
	add_child(_burn_timer)
	_active_burns = []

#region Movement and ability inputs
func get_input() -> void:
	if can_control_unit:
		playerDirection = Input.get_vector("move_left", "move_right", "move_up", "move_down")
		velocity = velocity.lerp(playerDirection * moveSpeed, 0.15)

func get_ability_inputs() -> void:
	if not can_control_unit:
		return
	if Input.is_action_pressed("use_ability"):
		if q_moves.ability_type == QMoves.AbilityType.Q_NONE:
			return
		if can_use_ability:
			ability_cooldown = max_ability_cooldown
			activate_player_ability()
			can_use_ability = false
			ability_visual_feedback.play("AbilityActivationVisual")
	else:
		secondary_fire_active = false

func activate_player_ability() -> void:
	q_moves.activate()
	ability_aoe_node.show()
#endregion

#region Main processes
func _process(delta):
	shot_fire_rate += delta

	## Tikbalang Step timer decay
	if tikbalang_step and tikbalang_speed_timer > 0.0:
		tikbalang_speed_timer -= delta
		moveSpeed = maxMoveSpeed * tikbalang_speed_bonus
	elif tikbalang_step and tikbalang_speed_timer <= 0.0:
		moveSpeed = maxMoveSpeed

	## Nuno Root — regen health while standing still
	if nuno_root:
		_process_nuno_root(delta)

	## Diwata Veil — invulnerability timer
	if diwata_invulnerable:
		_diwata_timer -= delta
		if _diwata_timer <= 0.0:
			diwata_invulnerable = false

	## Pause / game over checks
	if manager.gamePaused:
		process_mode = Node.PROCESS_MODE_INHERIT
		can_control_unit = false
	else:
		process_mode = Node.PROCESS_MODE_ALWAYS
		can_control_unit = true

	if cutscene_handler.game_is_over or cutscene_handler.game_is_won:
		process_mode = Node.PROCESS_MODE_INHERIT
		can_control_unit = false

	## Ability functions
	get_ability_inputs()
	ability_cooldown -= delta
	if ability_cooldown < 0.0:
		can_use_ability = true

	## Sprite rotations and animations
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

func _physics_process(_delta: float):
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
	shot_fire_rate = 0.0

	var spawn_pos := global_position + _get_facing_offset()
	var spawn_rotation := _get_projectile_rotation_from_spawn(spawn_pos)

	var this_shot_is_kapre := false
	if kapre_smoke:
		kapre_shot_counter += 1
		if kapre_shot_counter >= 8:
			kapre_shot_counter = 0
			this_shot_is_kapre = true

	if charge_shot.consume(modifier):
		shot_sound.play()
	else:
		#var projectile_instance = projectile.instantiate()
		#shot_sound.play()

		var projectile_instance = prototype_pool.get_projectile()

		if projectile_instance != null:
			shot_sound.play()

		var final_damage := projectile_damage * modifier * projectile_damage_multiplier
		projectile_instance.change_damage(int(final_damage))
		projectile_instance.change_projectile_side(ProjectileCommon.ProjectileSide.Player)
		projectile_instance.change_projectile_modulation(color)
		projectile_instance.position = spawn_pos
		projectile_instance.rotation_degrees = spawn_rotation
		if this_shot_is_kapre:
			projectile_instance.is_kapre_shot = true
			projectile_instance.kapre_damage = final_damage * 1.5
		if projectile_size_multiplier != 1.0:
			projectile_instance.set_projectile_size(projectile_size_multiplier)
		if projectile_speed_multiplier != 1.0:
			projectile_instance.projectileVelocity *= projectile_speed_multiplier

		projectile_instance.get_node("OrbitingParticles").set_effect_color(color)
		#world_parent.call_deferred("add_child", projectile_instance)

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

@export var projectile_spawn_offset: float = 20.0

func _on_perfect_hit() -> void:
	perfect_chain += 1
	if tikbalang_step:
		tikbalang_speed_timer = 1.25
	if perfect_chain >= 4:
		_enable_comet_projectile()
	if perfect_chain >= 8 and not cadence_mode:
		_enter_cadence_mode()
	if perfect_chain >= 16:
		_trigger_echo_nova()

func _on_missed_beat() -> void:
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

@export var chain_tier_panel: ChainTierPanel

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
	if chain_tier_panel:
		chain_tier_panel.show_tier(tier)

func _clear_chain_visuals() -> void:
	if chain_tier_ui:
		chain_tier_ui.reset_tier()
	if chain_border_glow:
		chain_border_glow.clear()
	if chain_aura:
		chain_aura.set_tier(0, Color.WHITE)
	if chain_tier_panel:
		chain_tier_panel.hide_panel()

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

	var nova_radius_sq: float = 400.0 * 400.0
	var player_pos := global_position
	var nova_dmg: int = int(projectile_damage * 3.0)
	var enemies := get_tree().get_nodes_in_group("GeneralEnemyInstance")

	for enemy in enemies:
		if not enemy:
			continue
		if enemy.has_method("modify_health"):
			if player_pos.distance_squared_to(enemy.global_position) <= nova_radius_sq:
				enemy.modify_health(-nova_dmg)

	## Spawn AoE damage zone at player
	var nova := pulse_aoe.instantiate()
	nova.change_damage(int(projectile_damage * 2.0))
	nova.position = player_pos
	nova.scale = Vector2(4.0, 4.0)
	get_tree().get_root().add_child(nova)

	## Big camera trauma
	camera.add_trauma(1.5)

	## Full screen flash
	if hit_flash:
		hit_flash.nova_flash()

	var nova_ring := NOVA_RING_SCENE.instantiate()
	nova_ring.position = player_pos
	nova_ring.max_radius = 1000.0
	get_tree().get_root().add_child(nova_ring)

	## Notify companions — single group query with append_array (avoids array copy from +)
	var companions := get_tree().get_nodes_in_group("Companion1")
	companions.append_array(get_tree().get_nodes_in_group("Companion2"))
	for companion in companions:
		if companion and companion.visible:
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

func _get_projectile_rotation_from_spawn(spawn_pos: Vector2) -> float:
	var mouse_pos := get_global_mouse_position()
	var direction := mouse_pos - spawn_pos
	return rad_to_deg(direction.angle())

func _get_projectile_rotation() -> float:
	## Rotate projectile toward mouse regardless of spawn offset
	var mouse_dir := get_global_mouse_position() - global_position
	return rad_to_deg(mouse_dir.angle())

func increment_player_charge_attack() -> void:
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

	var shotEffect = projectileShotEffect.instantiate()
	shotEffect.position = self.get_global_position()
	get_tree().get_root().call_deferred("add_child", shotEffect)
	print_debug("Damage: %s" % (projectile_damage / 1.75))

#region Player stat modifications
func modify_current_player_health(modification: int) -> void:
	if modification < 0 and diwata_invulnerable:
		print("Diwata Veil blocked damage!")
		return

	var old_health := healthPoints
	healthPoints += modification

	# Only emit and trigger effects if health actually changed
	if not is_equal_approx(healthPoints, old_health):
		print("Player HP is now: ", healthPoints)
		send_current_health.emit(healthPoints)

		if modification < 0:
			camera.add_trauma(0.8)
			if hit_flash:
				hit_flash.flash()
			hit_sound.play()
			var combo := get_tree().get_first_node_in_group("ComboManager")
			if combo:
				combo._subtract_combo_level()

	if healthPoints <= 0.0 and old_health > 0.0:
		camera.add_trauma(1.0)
		print("Game Over!")
		can_control_unit = false
		cutscene_handler.game_is_over = true
		get_tree().paused = true

func modify_current_xp(modification: int) -> void:
	experiencePoints += modification
	if experiencePoints >= maxExperiencePoints:
		upgrade_player_stats()
	else:
		send_current_xp.emit(experiencePoints)

func upgrade_player_stats() -> void:
	player_level += 1
	PointSystemScript.player_levels = player_level
	maxHealthPoints *= 1.04
	projectile_damage *= 1.06
	grenade_damage *= 1.05
	maxExperiencePoints = int(maxExperiencePoints * 1.04)
	experiencePoints = 0
	healthPoints += maxHealthPoints / 5.0
	if healthPoints > maxHealthPoints:
		healthPoints = maxHealthPoints

	var levelUpEffect = upgradeEffect.instantiate()
	levelUpEffect.position = self.get_global_position()
	get_tree().get_root().call_deferred("add_child", levelUpEffect)

	send_current_xp.emit(experiencePoints)
	send_maximum_xp.emit(maxExperiencePoints)
	send_maximum_health.emit(maxHealthPoints)
	companion_upgrade.emit()

	if UpgradeSystemScript.should_show_upgrades(player_level):
		UpgradeScreen.visible = true
		UpgradeScreen.show_upgrades(self)
#endregion

#region Agimats Implementation
func _process_nuno_root(delta: float) -> void:
	if velocity.length() < NUNO_STILL_THRESHOLD:
		_nuno_root_timer += delta
		if _nuno_root_timer >= NUNO_REGEN_INTERVAL:
			_nuno_root_timer = 0.0
			modify_current_player_health(int(NUNO_REGEN_AMOUNT))
	else:
		_nuno_root_timer = 0.0

func _trigger_diwata_veil() -> void:
	diwata_invulnerable = true
	_diwata_timer = 1.0

func _shoot_sarimanok_spread(modifier: float, color: Color) -> void:
	var spread_angles := [-18.0, 18.0]
	var spawn_pos := global_position + _get_facing_offset()
	var base_rotation := _get_projectile_rotation_from_spawn(spawn_pos)
	for angle_offset in spread_angles:
		var spread_projectile = projectile.instantiate()
		spread_projectile.change_damage(projectile_damage * modifier * 0.6)
		spread_projectile.change_projectile_side(ProjectileCommon.ProjectileSide.Player)
		spread_projectile.change_projectile_modulation(color)
		spread_projectile.position = spawn_pos
		spread_projectile.rotation_degrees = base_rotation + angle_offset
		spread_projectile.hit_combo_value = 0.0
		get_tree().get_root().call_deferred("add_child", spread_projectile)

func _shoot_kapre_explosion(modifier: float, color: Color) -> void:
	var spawn_pos := global_position + _get_facing_offset()
	var spawn_rotation := _get_projectile_rotation_from_spawn(spawn_pos)
	var aoe = pulse_aoe.instantiate()
	aoe.change_damage(int(projectile_damage * modifier * 1.5))
	aoe.position = spawn_pos
	get_tree().get_root().call_deferred("add_child", aoe)
	var smoke = kapre_smoke_effect.instantiate()
	smoke.position = spawn_pos
	get_tree().get_root().call_deferred("add_child", smoke)
	camera.add_trauma(0.4)

func _apply_harana_flame(enemy: Node) -> void:
	if not enemy.has_method("modify_health"):
		return
	_active_burns.append({
		"enemy": enemy,
		"ticks": 3,
		"damage": int(projectile_damage * 0.2)
	})
	if _burn_timer.is_stopped():
		_burn_timer.start()

func _on_burn_tick() -> void:
	var i: int = _active_burns.size() - 1
	while i >= 0:
		var burn = _active_burns[i]
		var enemy = burn.enemy
		if is_instance_valid(enemy):
			enemy.modify_health(-burn.damage)
		burn.ticks -= 1
		if burn.ticks <= 0 or not is_instance_valid(enemy):
			_active_burns.remove_at(i)
		i -= 1
	if _active_burns.is_empty():
		_burn_timer.stop()

func _shoot_echo(modifier: float, color: Color) -> void:
	await get_tree().create_timer(0.15).timeout
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
