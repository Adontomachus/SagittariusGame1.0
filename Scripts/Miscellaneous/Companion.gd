class_name CompanionGroup
extends CharacterBody2D

## Which role this companion plays — set in inspector per companion scene
enum CompanionRole {
	MELEE_STRIKER,   ## Companion 1 — aggressive, beat-synced, dash attacker
	RANGED_SUPPORT   ## Companion 2 — ranged, chain-reactive, buffer
}

@onready var cat_sprite: Sprite2D = $CatSprite

@export var role: CompanionRole = CompanionRole.MELEE_STRIKER

#region Variables with export groups
@export_group("State Machine")
@export var state_machine: CompanionStateMachine

@export_group("Other Variables")
@export var companion_sprite: Sprite2D
@export var pathfinding: NavigationAgent2D

@export_group("Companion Stats")
@export var move_speed: float

@export_group("Player Master")
var player_target: CharacterBody2D
@export var player_radius: float

#endregion

@onready var target_looker: Marker2D = $NearestEnemyTarget
@onready var master_target_location: Marker2D = $PlayerTarget
@onready var enemy_target_marker: Sprite2D = $EnemyTargetMarker

@export_group("Attacking Stats")
@export var dash_speed: float = 750
@export var companion_damage: float = 30
@export var dash_duration: float = 0.5
var is_dashing: bool = false

var damageNumber := preload("res://Objects/UI Elements/DamageNumbers.tscn")
var projectile_scene := preload("res://Objects/Instances With Collision/PrototypeProjectile.tscn")

@export var companion_hitbox: CollisionShape2D
var nearest_enemy: CharacterBody2D = null

var base_move_speed: float
var base_dash_speed: float
var base_companion_damage: float
var base_hitbox_radius: float
var current_level: int = 0

@export var aggressiveness: float = 1

var beat_sync: BeatSync_Script
var last_beat: float = 0.0

var current_chain_tier: int = 0  

## Striker-specific
var beat_charge: int = 0        
var max_beat_charge: int = 3      
var strike_particles: GPUParticles2D

## Support-specific
var support_shot_cooldown: float = 0.0
var support_buff_active: bool = false
var support_buff_timer: float = 0.0
@export var support_projectile_speed: float = 600.0
@export var support_shot_interval: float = 1.2


func _ready() -> void:
	cat_sprite.global_rotation = 0
	state_machine.init(self)
	player_target = get_tree().get_first_node_in_group("PlayerObject")

	base_move_speed = move_speed
	base_dash_speed = dash_speed
	base_companion_damage = companion_damage
	if companion_hitbox and companion_hitbox.shape is CircleShape2D:
		base_hitbox_radius = companion_hitbox.shape.radius

	beat_sync = get_tree().get_first_node_in_group("BeatSync")
	if beat_sync:
		beat_sync.beat_happened.connect(_on_beat)
		beat_sync.full_beat_happened.connect(_on_full_beat)

	visible = false
	process_mode = Node.PROCESS_MODE_DISABLED


func _process(delta: float) -> void:
	cat_sprite.global_rotation = 0
	nearest_enemy = _find_closest_enemy()
	if nearest_enemy:
		enemy_target_marker.global_position = nearest_enemy.global_position
		enemy_target_marker.visible = true
	else:
		enemy_target_marker.visible = false

	state_machine.process_frame(delta)

	## Chain tier tracking — read from player every frame
	if player_target and player_target is PlayerCharacter:
		_update_chain_reaction(player_target.perfect_chain)

	## Support cooldown
	if role == CompanionRole.RANGED_SUPPORT:
		support_shot_cooldown -= delta
		if support_buff_active:
			support_buff_timer -= delta
			if support_buff_timer <= 0:
				support_buff_active = false
				_deactivate_support_buff()


func _on_beat() -> void:
	match role:
		CompanionRole.MELEE_STRIKER:
			_striker_on_beat()
		CompanionRole.RANGED_SUPPORT:
			_support_on_beat()


func _on_full_beat() -> void:
	match role:
		CompanionRole.MELEE_STRIKER:
			_striker_on_full_beat()

func _striker_on_beat() -> void:
	beat_charge = min(beat_charge + 1, max_beat_charge)
	## Visual feedback — sprite brightens as charge builds
	if companion_sprite:
		var charge_ratio := float(beat_charge) / float(max_beat_charge)
		companion_sprite.modulate = Color(
			1.0 + charge_ratio * 0.5,
			1.0,
			1.0 - charge_ratio * 0.3,
			1.0
		)


func _striker_on_full_beat() -> void:
	## Every full beat, release charge as a powered strike if near an enemy
	if beat_charge >= max_beat_charge and nearest_enemy != null:
		var dist := global_position.distance_to(nearest_enemy.global_position)
		if dist < 200.0:
			_striker_powered_strike()


func _striker_powered_strike() -> void:
	if nearest_enemy == null:
		return
	## Powered strike — extra damage burst + shockwave
	nearest_enemy.modify_health(-int(companion_damage * 2.0 * aggressiveness))

	## Spawn a small AoE shockwave at the enemy position
	var aoe := preload("res://Objects/Instances With Collision/SplashDamage.tscn").instantiate()
	aoe.change_damage(int(companion_damage * 0.5))
	aoe.position = nearest_enemy.global_position
	get_tree().get_root().call_deferred("add_child", aoe)

	## Reset charge and tint
	beat_charge = 0
	if companion_sprite:
		companion_sprite.modulate = Color.WHITE

	## Damage number
	var dmg = damageNumber.instantiate()
	dmg.position = nearest_enemy.global_position + Vector2(-125, -105)
	dmg.damage_value = int(companion_damage * 2.0)
	dmg.is_critical_hit = true
	get_tree().get_root().call_deferred("add_child", dmg)

	print("Striker: powered strike!")


func _support_on_beat() -> void:
	## Fire a homing shot at nearest enemy on beat if cooldown is ready
	if nearest_enemy == null:
		return
	if support_shot_cooldown > 0:
		return
	_support_fire_shot()
	support_shot_cooldown = support_shot_interval / aggressiveness


func _support_fire_shot() -> void:
	if nearest_enemy == null:
		return
	var proj := projectile_scene.instantiate()
	proj.change_damage(int(companion_damage))
	proj.change_projectile_side(ProjectileCommon.ProjectileSide.Player)

	## Tint based on chain tier
	var shot_color := Color.WHITE
	match current_chain_tier:
		4: shot_color = Color(1.0, 0.8, 0.4)
		8: shot_color = Color(0.5, 0.9, 1.0)
		16: shot_color = Color(1.0, 0.3, 0.9)
	proj.change_projectile_modulation(shot_color)

	proj.position = global_position
	var dir := (nearest_enemy.global_position - global_position).normalized()
	proj.rotation_degrees = rad_to_deg(dir.angle())
	get_tree().get_root().call_deferred("add_child", proj)

func _update_chain_reaction(perfect_chain: int) -> void:
	var new_tier := 0
	if perfect_chain >= 16:
		new_tier = 16
	elif perfect_chain >= 8:
		new_tier = 8
	elif perfect_chain >= 4:
		new_tier = 4

	if new_tier == current_chain_tier:
		return

	var previous_tier := current_chain_tier
	current_chain_tier = new_tier

	## Tier went up
	if new_tier > previous_tier:
		_on_chain_tier_up(new_tier)
	## Chain broke
	elif new_tier == 0 and previous_tier > 0:
		_on_chain_broken()


func _on_chain_tier_up(tier: int) -> void:
	match role:
		CompanionRole.MELEE_STRIKER:
			var boost := 1.0 + (tier / 32.0)
			dash_speed = base_dash_speed * boost
			companion_damage = base_companion_damage * boost
			max_beat_charge = max(1, max_beat_charge - 1)  ## charges up faster
			print("Striker tier up: damage=", companion_damage, " charge_time=", max_beat_charge)

		CompanionRole.RANGED_SUPPORT:
			## Support activates a buff aura at higher tiers
			_activate_support_buff(tier)
			support_shot_interval = max(0.4, support_shot_interval - 0.2)  ## shoots faster
			print("Support tier up: shot_interval=", support_shot_interval)


func _on_chain_broken() -> void:
	match role:
		CompanionRole.MELEE_STRIKER:
			dash_speed = base_dash_speed
			companion_damage = base_companion_damage
			max_beat_charge = 3
			beat_charge = 0
			if companion_sprite:
				companion_sprite.modulate = Color.WHITE

		CompanionRole.RANGED_SUPPORT:
			support_shot_interval = 1.2
			support_buff_active = false
			_deactivate_support_buff()


func _activate_support_buff(tier: int) -> void:
	support_buff_active = true
	support_buff_timer = 5.0  ## buff lasts 5 seconds

	if player_target is PlayerCharacter and tier >= 8:
		player_target.projectile_damage_multiplier *= 1.2
		print("Support: buffed player damage")

	if companion_sprite:
		companion_sprite.modulate = Color(0.5, 0.9, 1.0)


func _deactivate_support_buff() -> void:
	## Remove the player damage buff when it expires
	if player_target is PlayerCharacter:
		player_target.projectile_damage_multiplier = max(
			1.0, player_target.projectile_damage_multiplier / 1.2
		)
	if companion_sprite:
		companion_sprite.modulate = Color.WHITE

func level_up(value: float) -> void:
	current_level += 1
	var multiplier := 1.0 + (value / 100.0)
	move_speed *= multiplier
	dash_speed *= multiplier
	companion_damage *= multiplier
	aggressiveness = clampf(aggressiveness + 0.2, 1.0, 2.5)
	if companion_hitbox and companion_hitbox.shape is CircleShape2D:
		companion_hitbox.shape.radius *= multiplier
	print("Companion leveled up to: ", current_level)


func reset_stats() -> void:
	current_level = 0
	move_speed = base_move_speed
	dash_speed = base_dash_speed
	companion_damage = base_companion_damage
	aggressiveness = 1.0
	beat_charge = 0
	current_chain_tier = 0
	support_buff_active = false
	support_shot_interval = 1.2
	max_beat_charge = 3
	if companion_hitbox and companion_hitbox.shape is CircleShape2D:
		companion_hitbox.shape.radius = base_hitbox_radius
	if companion_sprite:
		companion_sprite.modulate = Color.WHITE
	visible = false
	process_mode = Node.PROCESS_MODE_DISABLED


func move_companion(delta: float) -> void:
	var targetLocation = pathfinding.get_next_path_position()
	var new_velocity = global_position.direction_to(targetLocation) * move_speed
	velocity = new_velocity
	if pathfinding.avoidance_enabled:
		pathfinding.set_velocity(new_velocity)
	move_and_slide()


func _rush_towards_target(delta: float) -> void:
	var targetLocation = pathfinding.get_next_path_position()
	var new_velocity = global_position.direction_to(targetLocation) * dash_speed
	velocity = new_velocity
	if pathfinding.avoidance_enabled:
		pathfinding.set_velocity(new_velocity)
	move_and_slide()


func _physics_process(delta: float) -> void:
	target_looker.look_at(player_target.global_position)
	master_target_location.look_at(player_target.global_position)
	companion_sprite.look_at(player_target.global_position)
	state_machine.process_physics(delta)


func _find_closest_enemy() -> Object:
	var enemy_target = get_tree().get_nodes_in_group("GeneralEnemyInstance")
	nearest_enemy = null
	var minimum_distance := INF
	var max_range := 800.0 * aggressiveness
	for enemy in enemy_target:
		var target_distance = global_position.distance_squared_to(enemy.global_position)
		if target_distance < minimum_distance and target_distance < max_range * max_range:
			minimum_distance = target_distance
			nearest_enemy = enemy
	return nearest_enemy


func _on_player_companion_upgrade() -> void:
	companion_damage = companion_damage * 1.07
	
func on_echo_nova() -> void:
	match role:
		CompanionRole.MELEE_STRIKER:
			_striker_nova_response()
		CompanionRole.RANGED_SUPPORT:
			_support_nova_response()


func _striker_nova_response() -> void:
	## Striker goes berserk — instantly max charge, rush every nearby enemy
	## then slam back to player side
	beat_charge = max_beat_charge
	aggressiveness = clampf(aggressiveness * 2.0, 1.0, 5.0)

	## Flash red/orange
	if companion_sprite:
		var flash_tween := create_tween()
		flash_tween.tween_property(companion_sprite, "modulate",
			Color(2.0, 0.6, 0.1, 1.0), 0.05)
		flash_tween.tween_interval(0.5)
		flash_tween.tween_property(companion_sprite, "modulate",
			Color.WHITE, 0.4)\
			.set_trans(Tween.TRANS_SINE)

	## Hit every enemy within range simultaneously
	var nova_range := 500.0
	var enemies := get_tree().get_nodes_in_group("GeneralEnemyInstance")
	for enemy in enemies:
		if not is_instance_valid(enemy):
			continue
		var dist := global_position.distance_to(enemy.global_position)
		if dist <= nova_range and enemy.has_method("modify_health"):
			enemy.modify_health(-int(companion_damage * 3.0))
			## Spawn hit effect at each enemy
			var dmg := damageNumber.instantiate()
			dmg.position = enemy.global_position + Vector2(-125, -105)
			dmg.damage_value = int(companion_damage * 3.0)
			dmg.is_critical_hit = true
			get_tree().get_root().call_deferred("add_child", dmg)

	## Reset berserk after 3 seconds
	await get_tree().create_timer(3.0).timeout
	if is_instance_valid(self):
		aggressiveness = clampf(aggressiveness / 2.0, 1.0, 2.5)
		beat_charge = 0

	print("Striker: nova berserk!")


func _support_nova_response() -> void:
	## Support fires a ring of projectiles in all 8 directions\
	var directions := 12  ## fire 12 projectiles in a circle
	for i in range(directions):
		var angle := (TAU / directions) * i
		var proj := projectile_scene.instantiate()
		proj.change_damage(int(companion_damage * 2.0))
		proj.change_projectile_side(ProjectileCommon.ProjectileSide.Player)
		proj.change_projectile_modulation(Color(1.0, 0.3, 0.9))  ## nova pink
		proj.position = global_position
		proj.rotation_degrees = rad_to_deg(angle)
		get_tree().get_root().call_deferred("add_child", proj)

	## Flash pink/white
	if companion_sprite:
		var flash_tween := create_tween()
		flash_tween.tween_property(companion_sprite, "modulate",
			Color(1.5, 0.5, 2.0, 1.0), 0.05)
		flash_tween.tween_interval(0.3)
		flash_tween.tween_property(companion_sprite, "modulate",
			Color.WHITE, 0.5)\
			.set_trans(Tween.TRANS_SINE)

	## Strong damage buff to player for 8 seconds
	if player_target is PlayerCharacter:
		player_target.projectile_damage_multiplier *= 1.5
		print("Support: nova buff +50% player damage for 8s")

	## Remove buff after 8 seconds
	await get_tree().create_timer(8.0).timeout
	if is_instance_valid(self) and player_target is PlayerCharacter:
		player_target.projectile_damage_multiplier = max(
			1.0, player_target.projectile_damage_multiplier / 1.5
		)
		print("Support: nova buff expired")
