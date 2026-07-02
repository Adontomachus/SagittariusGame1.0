class_name Enemy
extends CharacterBody2D

@export_category("Visuals")
@export var allow_sprite_flip: bool = true

## For difficulty
var difficulty_settings = SaveSettings._load_difficulty_settings()

# HP Bar Stuff #
signal toggle_healthbar_visibility(visible: bool)
signal send_maximum_health_value(max_health: int)
signal send_current_health_value(health: int)

# Damage Flash Stuff #
signal pulse_damage_number

# Stacking Damage Number #
@export var stacking_damage_numbers: Label

#region
# TESTING: HP Bar for enemy boss units #
signal update_max_health_value(max_boss_health: int)
signal update_current_health_value(boss_health: int)
#endregion
@export var state_machine: EnemyStateMachine
@export var navAgent: NavigationAgent2D

## This boolean determines if the enemy is categorized as a boss.
## It controls whether a boss health bar should appear if the unit instantiates.
@export_category("Boss Unit Classification")
@export var boss_unit: bool = false

## The enemy's target. Usually the player, but it could also be an objective.
var target: CharacterBody2D

# STAMINA
@export_group("Movement Stats")
## The random range of the entity's maximum stamina
@export var stamina_range: Vector2 = Vector2(4, 8)
@export var stamina_regeneration_rate: float = 1.5
@export var maxMoveSpeed: float = 200.0
@export var movement_boosted: bool = false

var stamina: float:
	set(value):
		stamina = clampf(value, 0.0, maxStamina)
	get:
		return stamina
var maxStamina: float = randf_range(2,5)
var currentMoveSpeed

# VITALITY
@export_group("Vitality Stats")
@export var maxHealthPoints: int = 80
@export var meleeTickRate: int = 60
@export var amountOfPointOrbs: int = 3
var baseHealthPoints: int = 80

# PATHFINDING MECHANICS
@export_group("Pathfinding Variables")
@export var aroundPlayerRadius: float = 175.0
@export var repositioningTimer: float
@export var maxRepositioningTimer: float = 30.0

# SHOOTING
@export_group("Shooting")
@export var shoot_point: Marker2D
@export	var	inaccuracy: float = 12
func _on_navigation_agent_2d_velocity_computed(safe_velocity):
	velocity = safe_velocity
@export var attackPower: float
@export var projectile := preload("res://Objects/Instances With Collision/PrototypeProjectile.tscn")

# STACKING DAMAGE NUMBERS
@export_group("Stacking Damage Value")
@export var damageTaken: int = 0
var damageTakenDuration: float = 0

# OBJECTS SPAWNS ON DELETION
var destroyEffect := preload("res://Objects/Particle Effects/DestroyEffects.tscn")
var pointObject := preload("res://UnitInstances/Miscellaneous/ScoreOrb.tscn")

## How many times will the enemy try to shoot the player
@export var fire_rate: int = 5
## The minimum required roll to shoot from 0.0 to 10.0
@export_range(0.0, 10.0) var successfulChanceToAttack: float
## This variable is rolled randomly from 0, 10. Higher values 
## give the unit more chance to shoot the player for each beat.
var chanceToAttack: float
#@onready var hit_sound: AudioStreamPlayer = $HitSound
@onready var hit_flash_enemy: HitFlashEnemy = $HitFlashEnemy

# Damage number positioning and feedback visuals
var initPosition: Vector2 = Vector2(-133 ,-133)
var splash_damage_effect := preload("res://Objects/Particle Effects/AoEHitEffect.tscn")
## Damage number that spawns on side of the object's center
## when the object takes damage from AoE sources
var damageNumber := preload("res://Objects/UI Elements/DamageNumbers.tscn")
var tickDamageNumber := preload("res://Objects/UI Elements/TickDamageNumbers.tscn")
# START
func _ready():
	state_machine.init(self)#, animations, audio_sfx)
	
	# For boss type units, finds the node for the the cinematic handler to play a scene when the boss reaches 0 HP.
	#var cinematics_handler = get_tree().get_first_node_in_group("SceneGroup")
	#print("Current Cinematics Handler: " , cinematics_handler)
	# Enemy squashing and stretching
	var movement_stretch := get_node_or_null("MovementStretch")
	if movement_stretch:
		movement_stretch.sprite_to_wrap = state_machine.sprite
		movement_stretch.velocity_source = self
	
	var squash := get_node_or_null("BeatSquashStretch")
	if squash:
		squash.target = state_machine.sprite
		squash.full_beat_intensity = 0.025
		squash.half_beat_intensity = 0.01
		squash.recovery_speed = 0.9
		squash.base_scale = state_machine.sprite.scale
		print("Squash found in enemy")
	var hit_flash := get_node_or_null("HitFlashEnemy")
	if hit_flash:
		hit_flash.target = state_machine.sprite
		
	var difficultyScaler 
	
	if(difficulty_settings == 0):
		difficultyScaler = 0.75
	elif (difficulty_settings == 1):
		difficultyScaler = 1
	else:
		difficultyScaler = 1.25
	
	# Set enemy statistics
	maxStamina = randf_range(stamina_range.x, stamina_range.y)
	stamina = maxStamina
	currentMoveSpeed = maxMoveSpeed
	maxHealthPoints = (maxHealthPoints * difficultyScaler) * ScalingSystemScript.health_scaling
	attackPower = (attackPower * difficultyScaler) * ScalingSystemScript.attack_power_scaling
	baseHealthPoints = maxHealthPoints

	# Setup healthbar
	toggle_healthbar_visibility.emit(true) # Hide the health bar until damaged
	send_maximum_health_value.emit(maxHealthPoints)
	send_current_health_value.emit(baseHealthPoints)
	
	# For the boss healthbar
	if boss_unit:
		add_to_group("BossType")
		var boss_bar = get_tree().get_first_node_in_group("BossHealthUI")
		if boss_bar:
			boss_bar.visible = true
			update_max_health_value.connect(boss_bar._on_boss_update_max_health_value)
			update_current_health_value.connect(boss_bar._on_boss_update_current_health_value)
			update_max_health_value.emit(maxHealthPoints)
			update_current_health_value.emit(baseHealthPoints)
	
	# Get player for navigation and targeting
	target = get_tree().get_first_node_in_group("PlayerObject")

func _physics_process(delta: float) -> void:
	#region This section is for charging enemy units only
	if movement_boosted: currentMoveSpeed = 630
	else: currentMoveSpeed = maxMoveSpeed
	#endregion
	
	if target and shoot_point:
		shoot_point.look_at(target.global_position)
	# SPRITE FLIPPING
	if allow_sprite_flip and target:
		if target.global_position.x < global_position.x:
			state_machine.sprite.flip_h = true
		else:
			state_machine.sprite.flip_h = false
	else:
		state_machine.sprite.flip_h = false
	state_machine.process_physics(delta)
	
func _process(delta: float) -> void:
	state_machine.process_frame(delta)
	
	## Decrements the damage taken duration for stacking damage numbers
	damageTakenDuration -= 1 * delta
	if damageTakenDuration <= 0:
		damageTaken = 0

	

func move_enemy(delta: float) -> void:
	stamina -= delta

	var targetLocation = navAgent.get_next_path_position()
	var new_velocity = global_position.direction_to(targetLocation) * currentMoveSpeed
	
	velocity = new_velocity
	
	if (navAgent.avoidance_enabled):
		navAgent.set_velocity(new_velocity)

	move_and_slide()

# RECOVERY MODE
func recovery_mode(delta: float) -> bool:
	stamina += stamina_regeneration_rate * delta
	return stamina >= maxStamina

func shoot_projectile(angle: float = 0, modifier: float = 1.0, color: Color = Color.RED) -> void:
	var projectile_instance = projectile.instantiate()
	projectile_instance.change_damage(attackPower * modifier)
	projectile_instance.change_projectile_side(ProjectileCommon.ProjectileSide.Enemy)
	projectile_instance.change_projectile_modulation(color)
	projectile_instance.position = shoot_point.get_global_position()
	projectile_instance.rotation_degrees = shoot_point.rotation_degrees + angle + randf_range(-inaccuracy,inaccuracy)
	get_tree().get_root().call_deferred("add_child", projectile_instance)
	print_debug("Damage: %s" % (attackPower * modifier))
	
func shoot_slow_projectile(angle: float = 0, modifier: float = 1.0,
		color: Color = Color.RED, speed: float = 275.0, lifetime: float = 400) -> void:

	var projectile_instance = projectile.instantiate()
	projectile_instance.change_lifetime(lifetime)
	projectile_instance.change_velocity(speed)
	projectile_instance.change_damage(attackPower * modifier)
	projectile_instance.change_projectile_side(ProjectileCommon.ProjectileSide.Enemy)
	projectile_instance.change_projectile_modulation(color)
	projectile_instance.set_projectile_size(2)

	projectile_instance.position = shoot_point.global_position
	projectile_instance.rotation_degrees = shoot_point.rotation_degrees + angle + randf_range(-inaccuracy, inaccuracy)

	get_tree().root.call_deferred("add_child", projectile_instance)


func modify_health(increment: int) -> void:
	#hit_sound.play()
	baseHealthPoints += increment
	send_current_health_value.emit(baseHealthPoints)

	# Boss
	update_current_health_value.emit(baseHealthPoints)
	toggle_healthbar_visibility.emit(baseHealthPoints < maxHealthPoints)
	if increment < 0 and hit_flash_enemy:
		hit_flash_enemy.flash()
	
	if (baseHealthPoints < 0):
		_delete_and_emit_effects()
		
# DESTROY EFFECTS
func _delete_and_emit_effects():
	var deathEffect = destroyEffect.instantiate()
	deathEffect.position = self.get_global_position()
	get_tree().get_root().call_deferred("add_child", deathEffect)
	
	## Rewards the player with experience points upon elimination
	
	for xp in range(amountOfPointOrbs):
		print("ENEMY DESTROYED AND PLAYER REWARDED")
		var rewards = pointObject.instantiate()
		rewards.orb_level = 1
		rewards.position = self.get_global_position()
		get_tree().get_root().call_deferred("add_child", rewards)

	call_deferred("queue_free")
	
	## If the unit is considered the "final boss of the level", play a cutscene 
	## of the boss getting defeated and roll out victorious post game statistics
	if boss_unit:
		## Completely disables the enemy object and plays the winning animation
		var cinematics_handler = get_tree().get_first_node_in_group("SceneGroup")
		print("Current Cinematics Handler: " , cinematics_handler)
		cinematics_handler.game_is_won = true
		self.set_process(false)
		
		get_tree().paused = true
		
		# Updates current level and unlocks next levels
		LevelManager.currentLevel += 1 
		LevelManager._unlock_level(LevelManager.currentLevel)
		
		return
	return
	
func _aoe_damage_feedback(increment: int):
	## Damage Number
	var damageFeedback = tickDamageNumber.instantiate()
	damageFeedback.position = self.get_global_position() + initPosition
	damageFeedback.damage_value = increment
	get_tree().get_root().call_deferred("add_child", damageFeedback)
	## Damage visuals
	var hitEffect = splash_damage_effect.instantiate()
	hitEffect.position = self.get_global_position()
	get_tree().get_root().call_deferred("add_child", hitEffect)
	pass


#func change_unit_stats(health: int, new_damage: int) -> void:

func _stack_damage(damage_value: int) -> void:
	damageTakenDuration = 1
	damageTaken += damage_value
	if stacking_damage_numbers:
		pulse_damage_number.emit()
		stacking_damage_numbers.text = str(round(damageTaken))
	pass # Replace with function body.
