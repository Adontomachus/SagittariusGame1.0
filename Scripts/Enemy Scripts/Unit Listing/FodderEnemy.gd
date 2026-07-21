class_name Enemy
extends CharacterBody2D

var clickable_tome := preload("res://Objects/Instances With Collision/ClickableTome.tscn")

@export_category("Visuals")
@export var allow_sprite_flip: bool = true

## For difficulty
var difficulty_settings = SaveSettings._load_difficulty_settings()

# HP Bar Stuff
signal toggle_healthbar_visibility(visible: bool)
signal send_maximum_health_value(max_health: int)
signal send_current_health_value(health: int)

# Damage Flash Stuff
signal pulse_damage_number

# Stacking Damage Number
@export var stacking_damage_numbers: Label

# TESTING: HP Bar for enemy boss units
signal update_max_health_value(max_boss_health: int)
signal update_current_health_value(boss_health: int)

@export var state_machine: EnemyStateMachine
@export var navAgent: NavigationAgent2D

## This boolean determines if the enemy is categorized as a boss.
@export_category("Boss Unit Classification")
@export var boss_unit: bool = false

## The enemy's target. Usually the player, but it could also be an objective.
var target: CharacterBody2D

# STAMINA
@export_group("Movement Stats")
@export var stamina_range: Vector2 = Vector2(4, 8)
@export var stamina_regeneration_rate: float = 1.5
@export var maxMoveSpeed: float = 200.0
@export var movement_boosted: bool = false

var stamina: float:
	set(value):
		stamina = clampf(value, 0.0, maxStamina)
	get:
		return stamina

var maxStamina: float = randf_range(2, 5)
var currentMoveSpeed: float

# VITALITY
@export_group("Vitality Stats")
@export var maxHealthPoints: int = 80
@export var meleeTickRate: int = 60
@export var amountOfPointsInOrb: int = 3

var baseHealthPoints: int = 80

# PATHFINDING MECHANICS
@export_group("Pathfinding Variables")
@export var aroundPlayerRadius: float = 175.0
@export var repositioningTimer: float
@export var maxRepositioningTimer: float = 30.0

# SHOOTING
@export_group("Shooting")
@export var shoot_point: Marker2D
@export var inaccuracy: float = 12.0

@export var attackPower: float
@export var projectile := preload("res://Objects/Instances With Collision/PrototypeProjectile.tscn")

# STACKING DAMAGE NUMBERS
@export_group("Stacking Damage Value")
@export var damageTaken: int = 0
var damageTakenDuration: float = 0.0

# OBJECTS SPAWNS ON DELETION
var destroyEffect := preload("res://Objects/Particle Effects/DestroyEffects.tscn")
var pointObject := preload("res://UnitInstances/Miscellaneous/ScoreOrb.tscn")

## How many times will the enemy try to shoot the player
@export var fire_rate: int = 5
## The minimum required roll to shoot from 0.0 to 10.0
@export_range(0.0, 10.0) var successfulChanceToAttack: float
var chanceToAttack: float

@onready var hit_flash_enemy: HitFlashEnemy = $HitFlashEnemy

# Damage number positioning and feedback visuals
var initPosition: Vector2 = Vector2(-133, -133)
var splash_damage_effect := preload("res://Objects/Particle Effects/AoEHitEffect.tscn")
var damageNumber := preload("res://Objects/UI Elements/DamageNumbers.tscn")
var tickDamageNumber := preload("res://Objects/UI Elements/TickDamageNumbers.tscn")

#region Cached References (avoid repeated tree lookups)
var _root: Window
var _scene_group: Node
var _boss_bar: Node
var _last_flip_h: bool = false
var _cached_difficulty_scaler: float = 1.0
#endregion

func _ready():
	_root = get_tree().root
	_scene_group = get_tree().get_first_node_in_group("SceneGroup")

	state_machine.init(self)

	# Enemy squashing and stretching
	var movement_stretch := get_node_or_null("MovementStretch")
	if movement_stretch:
		movement_stretch.sprite_to_wrap = state_machine.sprite
		movement_stretch.velocity_source = self
	var hit_flash := get_node_or_null("HitFlashEnemy")
	if hit_flash:
		hit_flash.target = state_machine.sprite

	# Cache difficulty scaler
	match difficulty_settings:
		0: _cached_difficulty_scaler = 0.75
		1: _cached_difficulty_scaler = 1.0
		_: _cached_difficulty_scaler = 1.25

	# Set enemy statistics
	maxStamina = randf_range(stamina_range.x, stamina_range.y)
	stamina = maxStamina
	currentMoveSpeed = maxMoveSpeed
	maxHealthPoints = int(maxHealthPoints * _cached_difficulty_scaler * ScalingSystemScript.health_scaling)
	attackPower = attackPower * _cached_difficulty_scaler * ScalingSystemScript.attack_power_scaling
	baseHealthPoints = maxHealthPoints

	# Setup healthbar
	toggle_healthbar_visibility.emit(true)
	send_maximum_health_value.emit(maxHealthPoints)
	send_current_health_value.emit(baseHealthPoints)

	# Boss healthbar setup
	if boss_unit:
		toggle_healthbar_visibility.emit(false)
		add_to_group("BossType")
		_boss_bar = get_tree().get_first_node_in_group("BossHealthUI")
		if _boss_bar:
			_boss_bar.visible = true
			update_max_health_value.connect(_boss_bar._on_boss_update_max_health_value)
			update_current_health_value.connect(_boss_bar._on_boss_update_current_health_value)
			update_max_health_value.emit(maxHealthPoints)
			update_current_health_value.emit(baseHealthPoints)

	# Cache player target
	target = get_tree().get_first_node_in_group("PlayerObject")

func _physics_process(delta: float) -> void:
	if movement_boosted:
		currentMoveSpeed = 630.0
	else:
		currentMoveSpeed = maxMoveSpeed

	if target and shoot_point:
		shoot_point.look_at(target.global_position)

	# SPRITE FLIPPING — only set when changed
	if allow_sprite_flip and target:
		var should_flip: bool = target.global_position.x < global_position.x
		if should_flip != _last_flip_h:
			_last_flip_h = should_flip
			state_machine.sprite.flip_h = should_flip
	else:
		if _last_flip_h:
			_last_flip_h = false
			state_machine.sprite.flip_h = false

	state_machine.process_physics(delta)

func _process(delta: float) -> void:
	state_machine.process_frame(delta)

	## Decrements the damage taken duration for stacking damage numbers
	damageTakenDuration -= delta
	if damageTakenDuration <= 0.0:
		damageTaken = 0

func move_enemy(delta: float) -> void:
	stamina -= delta
	var targetLocation := navAgent.get_next_path_position()
	var new_velocity := global_position.direction_to(targetLocation) * currentMoveSpeed
	velocity = new_velocity
	if navAgent.avoidance_enabled:
		navAgent.set_velocity(new_velocity)
	move_and_slide()

# RECOVERY MODE
func recovery_mode(delta: float) -> bool:
	stamina += stamina_regeneration_rate * delta
	return stamina >= maxStamina

func shoot_projectile(angle: float = 0, modifier: float = 1.0, color: Color = Color.RED) -> void:
	var projectile_instance := projectile.instantiate()
	projectile_instance.change_damage(attackPower * modifier)
	projectile_instance.change_projectile_side(ProjectileCommon.ProjectileSide.Enemy)
	projectile_instance.change_projectile_modulation(color)
	projectile_instance.position = shoot_point.get_global_position()
	projectile_instance.rotation_degrees = shoot_point.rotation_degrees + angle + randf_range(-inaccuracy, inaccuracy)
	_root.call_deferred("add_child", projectile_instance)
	print_debug("Damage: %s" % (attackPower * modifier))

func shoot_slow_projectile(angle: float = 0, modifier: float = 1.0,
		color: Color = Color.RED, speed: float = 275.0, lifetime: float = 400) -> void:
	var projectile_instance := projectile.instantiate()
	projectile_instance.change_lifetime(lifetime)
	projectile_instance.change_velocity(speed)
	projectile_instance.change_damage(attackPower * modifier)
	projectile_instance.change_projectile_side(ProjectileCommon.ProjectileSide.Enemy)
	projectile_instance.change_projectile_modulation(color)
	projectile_instance.set_projectile_size(2)
	projectile_instance.position = shoot_point.global_position
	projectile_instance.rotation_degrees = shoot_point.rotation_degrees + angle + randf_range(-inaccuracy, inaccuracy)
	_root.call_deferred("add_child", projectile_instance)

func modify_health(increment: int) -> void:
	var old_health := baseHealthPoints
	baseHealthPoints += increment

	# Only emit signals when health actually changes
	if baseHealthPoints != old_health:
		send_current_health_value.emit(baseHealthPoints)
		if boss_unit:
			update_current_health_value.emit(baseHealthPoints)
		toggle_healthbar_visibility.emit(baseHealthPoints < maxHealthPoints)

	if increment < 0 and hit_flash_enemy:
		hit_flash_enemy.flash()

	if baseHealthPoints <= 0:
		_delete_and_emit_effects()

# DESTROY EFFECTS
func _delete_and_emit_effects():
	var deathEffect := destroyEffect.instantiate()
	deathEffect.position = global_position
	_root.call_deferred("add_child", deathEffect)

	print("ENEMY DESTROYED AND PLAYER REWARDED")
	var rewards := pointObject.instantiate()
	rewards.experienceAmount = amountOfPointsInOrb
	rewards.healAmount = 1
	rewards.position = global_position
	_root.call_deferred("add_child", rewards)

	queue_free()

	## Boss defeat sequence
	if boss_unit:
		print("Current Cinematics Handler: ", _scene_group)

		# Fast group call instead of tree traversal + manual iteration
		get_tree().call_group("GeneralEnemyInstance", "modify_health", -9999999999)

		## Spawn the tome at the boss's position
		var tome := clickable_tome.instantiate()
		tome.global_position = global_position
		get_tree().current_scene.call_deferred("add_child", tome)
		print("Tome spawned — waiting for player to interact")

		set_process(false)

func _aoe_damage_feedback(increment: int):
	var damageFeedback := tickDamageNumber.instantiate()
	damageFeedback.position = global_position + initPosition
	damageFeedback.damage_value = increment
	_root.call_deferred("add_child", damageFeedback)

	var hitEffect := splash_damage_effect.instantiate()
	hitEffect.position = global_position
	_root.call_deferred("add_child", hitEffect)

func _stack_damage(damage_value: int) -> void:
	damageTakenDuration = 1.0
	damageTaken += damage_value
	if stacking_damage_numbers:
		pulse_damage_number.emit()
		stacking_damage_numbers.text = str(round(damageTaken))
