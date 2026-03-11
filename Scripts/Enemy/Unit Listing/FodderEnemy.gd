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
## The enemy's target. Usually the player, but it could also be an objective.
var target: CharacterBody2D

# STAMINA
@export_group("Movement Stats")
## The random range of the entity's maximum stamina
@export var stamina_range: Vector2 = Vector2(2, 5)
@export var stamina_regeneration_rate: float = 1.0
@export var maxMoveSpeed: float = 100.0
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
var healthPoints: int = 80

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


# START
func _ready():
	# maxHealthPoints = BeatSync.tempo
	state_machine.init(self)#, animations, audio_sfx)

	# Set enemy stats
	maxStamina = randf_range(stamina_range.x, stamina_range.y)
	stamina = maxStamina
	currentMoveSpeed = maxMoveSpeed
	healthPoints = maxHealthPoints

	# Setup healthbar
	toggle_healthbar_visibility.emit(false) # Hide the health bar until damaged
	send_maximum_health_value.emit(maxHealthPoints)
	send_current_health_value.emit(healthPoints)
	
	# For the boss healthbar
	update_max_health_value.emit(maxHealthPoints)
	update_current_health_value.emit(healthPoints)
	

	
	# Get player for navigation and targeting
	target = get_tree().get_first_node_in_group("PlayerObject")

func _physics_process(delta: float) -> void:
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
	healthPoints += increment
	send_current_health_value.emit(healthPoints)
	
	# Boss
	update_current_health_value.emit(healthPoints)
	
	toggle_healthbar_visibility.emit(healthPoints < maxHealthPoints)
	#update_max_health_value.emit(healthPoints)
	#update_current_health_value(boss_health: int)
	if (healthPoints < 0):
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
	return
