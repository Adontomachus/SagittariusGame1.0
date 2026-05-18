class_name Enemy
extends CharacterBody2D

# HP Bar Stuff #
signal toggle_healthbar_visibility(visible: bool)
signal send_maximum_health_value(max_health: int)
signal send_current_health_value(health: int)

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
@export var stamina_range: Vector2 = Vector2(2, 5)
@export var stamina_regeneration_rate: float = 1.0
@export var maxMoveSpeed: float = 100.0
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
@onready var hit_sound: AudioStreamPlayer = $HitSound

# Damage number positioning and feedback visuals
var initPosition: Vector2 = Vector2(-133 ,-133)
var splash_damage_effect := preload("res://Objects/Particle Effects/AoEHitEffect.tscn")
## Damage number that spawns on side of the object's center
## when the object takes damage from AoE sources
var damageNumber := preload("res://Objects/UI Elements/DamageNumbers.tscn")

# START
func _ready():
	state_machine.init(self)#, animations, audio_sfx)
	
	# For boss type units, finds the node for the the cinematic handler to play a scene when the boss reaches 0 HP.
	#var cinematics_handler = get_tree().get_first_node_in_group("SceneGroup")
	#print("Current Cinematics Handler: " , cinematics_handler)
	
	# Set enemy statistics
	maxStamina = randf_range(stamina_range.x, stamina_range.y)
	stamina = maxStamina
	currentMoveSpeed = maxMoveSpeed
	maxHealthPoints = maxHealthPoints * ScalingSystemScript.health_scaling
	attackPower = attackPower * ScalingSystemScript.attack_power_scaling
	baseHealthPoints = maxHealthPoints

	# Setup healthbar
	toggle_healthbar_visibility.emit(false) # Hide the health bar until damaged
	send_maximum_health_value.emit(maxHealthPoints)
	send_current_health_value.emit(baseHealthPoints)
	
	# For the boss healthbar
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
	if target.get_global_position().x < global_position.x:
		state_machine.sprite.flip_h = true
		# shotgun = global_position + weaponOffset
		#shotgun.flip_v = true
		pass
	else:
		state_machine.sprite.flip_h = false
	state_machine.process_physics(delta)
	
func _process(delta: float) -> void:
	state_machine.process_frame(delta)

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

func shoot_projectile(modifier: float = 1.0, color: Color = Color.RED) -> void:
	var projectile_instance = projectile.instantiate()
	projectile_instance.change_damage(attackPower * modifier)
	projectile_instance.change_projectile_side(ProjectileCommon.ProjectileSide.Enemy)
	projectile_instance.change_projectile_modulation(color)
	projectile_instance.position = shoot_point.get_global_position()
	projectile_instance.rotation_degrees = shoot_point.rotation_degrees + randf_range(-inaccuracy,inaccuracy)
	get_tree().get_root().call_deferred("add_child", projectile_instance)
	print_debug("Damage: %s" % (attackPower * modifier))

func modify_health(increment: int) -> void:
	hit_sound.play()
	baseHealthPoints += increment
	send_current_health_value.emit(baseHealthPoints)

	# Boss
	update_current_health_value.emit(baseHealthPoints)
	toggle_healthbar_visibility.emit(baseHealthPoints < maxHealthPoints)
	
	if (baseHealthPoints < 0):
		_delete_and_emit_effects()
		
# DESTROY EFFECTS
func _delete_and_emit_effects():
	var deathEffect = destroyEffect.instantiate()
	deathEffect.position = self.get_global_position()
	get_tree().get_root().call_deferred("add_child", deathEffect)
	for xp in range(amountOfPointOrbs):
		print("ENEMY DESTROYED AND PLAYER REWARDED")
		var rewards = pointObject.instantiate()
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
		return
	return
	
func _aoe_damage_feedback(increment: int):
	## Damage Number
	var damageFeedback = damageNumber.instantiate()
	damageFeedback.position = self.get_global_position() + initPosition
	damageFeedback.damage_value = increment
	get_tree().get_root().call_deferred("add_child", damageFeedback)
	## Damage visuals
	var hitEffect = splash_damage_effect.instantiate()
	hitEffect.position = self.get_global_position()
	get_tree().get_root().call_deferred("add_child", hitEffect)

	pass
# CHANGE STATS ON SPAWN (TENTATIVE)
#func change_unit_stats(health: int, new_damage: int) -> void:
