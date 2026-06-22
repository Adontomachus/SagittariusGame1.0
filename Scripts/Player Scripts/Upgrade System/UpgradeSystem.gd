class_name UpgradeSystem
extends Node

const UPGRADE_THRESHOLDS: Array[int] = [3, 5, 7, 10, 13, 16, 19, 22, 25, 28, 31, 34, 37, 40, 44, 48, 52, 56, 60]
const CARDS_TO_SHOW: int = 3

var all_upgrades: Array[UpgradeData] = []

signal upgrade_selected(upgrade: UpgradeData)


func _ready() -> void:
	_register_upgrades()


func _register_upgrades() -> void:
	## -------------------------
	## STAT UPGRADES
	## -------------------------
	all_upgrades.append(_make_upgrade(
		"stat_damage", "Strength",
		"Projectile damage +{value}%",
		UpgradeData.UpgradeCategory.STAT, 5,
		[10.0, 10.0, 12.0, 12.0, 15.0]
	))
	all_upgrades.append(_make_upgrade(
		"stat_move_speed", "Speed",
		"Move speed +{value}%",
		UpgradeData.UpgradeCategory.STAT, 5,
		[10.0, 10.0, 12.0, 12.0, 15.0]
	))
	all_upgrades.append(_make_upgrade(
		"stat_max_health", "Vitality",
		"Max health +{value}%",
		UpgradeData.UpgradeCategory.STAT, 5,
		[15.0, 15.0, 20.0, 20.0, 25.0]
	))

	## -------------------------
	## SECONDARY FIRE UPGRADES
	## -------------------------
	all_upgrades.append(_make_upgrade(
		"secondary_grenade_damage", "Hotter Flames",
		"Grenade damage +{value}%",
		UpgradeData.UpgradeCategory.SECONDARY_FIRE, 5,
		[15.0, 15.0, 20.0, 20.0, 25.0]
	))
	all_upgrades.append(_make_upgrade(
		"secondary_grenade_radius", "Bigger Flames",
		"Grenade radius +{value}%",
		UpgradeData.UpgradeCategory.SECONDARY_FIRE, 5,
		[15.0, 15.0, 20.0, 20.0, 25.0]
	))
	all_upgrades.append(_make_upgrade(
		"secondary_dash_force", "Swift Feet",
		"Dash force +{value}%",
		UpgradeData.UpgradeCategory.SECONDARY_FIRE, 5,
		[15.0, 15.0, 20.0, 20.0, 25.0]
	))
	all_upgrades.append(_make_upgrade(
		"secondary_swap_grenade", "Grenade",
		"Unlock grenade as secondary fire",
		UpgradeData.UpgradeCategory.SECONDARY_FIRE, 1,
		[1.0]
	))
	all_upgrades.append(_make_upgrade(
		"secondary_swap_dash", "Dash",
		"Unlock dashing as secondary fire",
		UpgradeData.UpgradeCategory.SECONDARY_FIRE, 1,
		[1.0]
		))
	## -------------------------
	## Q MOVE UPGRADES
	## -------------------------
	all_upgrades.append(_make_upgrade(
		"qmove_swap_cone", "Cone Burst",
		"Swap Q move to directional cone burst",
		UpgradeData.UpgradeCategory.Q_MOVE, 1,
		[1.0]
	))
	all_upgrades.append(_make_upgrade(
		"qmove_swap_aoe_pulse", "Rhythm Pulse",
		"Unlock Rhythm pulse as Q move",
		UpgradeData.UpgradeCategory.Q_MOVE, 1,
		[1.0]
	))
	all_upgrades.append(_make_upgrade(
		"qmove_aoe_damage", "Shockwave",
		"AoE pulse damage +{value}%",
		UpgradeData.UpgradeCategory.Q_MOVE, 5,
		[15.0, 15.0, 20.0, 20.0, 25.0]
	))
	all_upgrades.append(_make_upgrade(
		"qmove_aoe_duration", "Sustained Pulse",
		"AoE pulse duration +{value} beats",
		UpgradeData.UpgradeCategory.Q_MOVE, 5,
		[3.0, 3.0, 5.0, 5.0, 7.0]
	))
	all_upgrades.append(_make_upgrade(
		"qmove_cone_count", "Wider Spread",
		"Cone fires +{value} extra projectiles",
		UpgradeData.UpgradeCategory.Q_MOVE, 5,
		[1.0, 1.0, 2.0, 2.0, 3.0]
	))
	all_upgrades.append(_make_upgrade(
		"qmove_cone_damage", "Focused Fire",
		"Cone projectile damage +{value}%",
		UpgradeData.UpgradeCategory.Q_MOVE, 5,
		[15.0, 15.0, 20.0, 20.0, 25.0]
	))

	## -------------------------
	## CHARGE SHOT UPGRADES
	## -------------------------
	all_upgrades.append(_make_upgrade(
		"charge_damage", "Overcharge",
		"Charged shot damage multiplier +{value}",
		UpgradeData.UpgradeCategory.CHARGE_SHOT, 5,
		[0.5, 0.5, 0.8, 0.8, 1.0]
	))
	## -------------------------
	## COMPANION UPGRADES
	## -------------------------
	all_upgrades.append(_make_upgrade(
		"companion_1_unlock", "Unlock Companion 1",
		"Unlock your first companion",
		UpgradeData.UpgradeCategory.STAT, 1,
		[1.0]
	))
	all_upgrades.append(_make_upgrade(
		"companion_1_level", "Empower Companion 1",
		"Increase companion 1 power — speed +{value}%, damage +{value}%, bigger hitbox",
		UpgradeData.UpgradeCategory.STAT, 3,
		[15.0, 15.0, 20.0]
	))
	all_upgrades.append(_make_upgrade(
		"companion_2_unlock", "Unlock Companion 2",
		"Unlock your second companion",
		UpgradeData.UpgradeCategory.STAT, 1,
		[1.0]
	))
	all_upgrades.append(_make_upgrade(
		"companion_2_level", "Empower Companion 2",
		"Increase companion 2 power — speed +{value}%, damage +{value}%, bigger hitbox",
		UpgradeData.UpgradeCategory.STAT, 3,
		[15.0, 15.0, 20.0]
	))


func _make_upgrade(
		id: String, name: String, desc: String,
		category: UpgradeData.UpgradeCategory,
		max_level: int, values: Array[float]) -> UpgradeData:
	var u := UpgradeData.new()
	u.id = id
	u.display_name = name
	u.description_template = desc
	u.category = category
	u.max_level = max_level
	u.values_per_level = values
	return u


func should_show_upgrades(player_level: int) -> bool:
	return player_level in UPGRADE_THRESHOLDS


func get_random_cards(player: PlayerCharacter) -> Array[UpgradeData]:
	var available := all_upgrades.filter(func(u):
		return not u.is_maxed() and is_upgrade_available(u, player)
	)
	available.shuffle()
	return available.slice(0, min(CARDS_TO_SHOW, available.size()))


# Always update this when new moves or upgrades are added
func apply_upgrade(upgrade: UpgradeData, player: PlayerCharacter) -> void:
	if player == null:
			push_error("UpgradeSystem: player reference is null in apply_upgrade")
			return
	if player.q_moves == null:
			push_error("UpgradeSystem: player.q_moves is null — check QMoves node is assigned in inspector")
			return
	var value := upgrade.get_next_value()
	upgrade.current_level += 1

	match upgrade.id:
		## STATS — all multiplicative so they stack naturally
		"stat_damage":
			player.projectile_damage *= 1.0 + (value / 100.0)
		"stat_move_speed":
			player.moveSpeed *= 1.0 + (value / 100.0)
		"stat_max_health":
			player.maxHealthPoints *= 1.0 + (value / 100.0)
			player.healthPoints = player.maxHealthPoints
			player.send_maximum_health.emit(player.maxHealthPoints)
			player.send_current_health.emit(player.healthPoints)

		## SECONDARY
		"secondary_grenade_damage":
			player.grenade_damage *= 1.0 + (value / 100.0)
		"secondary_grenade_radius":
			## Stored on player, read by Grenade on launch
			player.grenade_radius *= 1.0 + (value / 100.0)
		"secondary_dash_force":
			player.dash_force *= 1.0 + (value / 100.0)
		"secondary_swap_grenade":
			var secondary = player.get_node("SecondaryFire")
			secondary.secondary_actions["secondary_fire"] = secondary._secondary_grenade
		"secondary_swap_dash":
			var secondary = player.get_node("SecondaryFire")
			secondary.secondary_actions["secondary_fire"] = secondary._secondary_dash

		## Q MOVE
		"qmove_swap_aoe_pulse":
			player.q_moves.ability_type = QMoves.AbilityType.AOE_PULSE
		"qmove_swap_cone":
			player.q_moves.ability_type = QMoves.AbilityType.DIRECTIONAL_CONE
		"qmove_aoe_damage":
			## Lower divisor = more damage
			player.q_moves.damage_divisor_min = max(0.4, player.q_moves.damage_divisor_min * (1.0 - value / 100.0))
			player.q_moves.damage_divisor_max = max(0.5, player.q_moves.damage_divisor_max * (1.0 - value / 100.0))
		"qmove_aoe_duration":
			player.q_moves.ability_duration_beats += int(value)
		"qmove_cone_count":
			player.q_moves.cone_projectile_count += int(value)
		"qmove_cone_damage":
			player.q_moves.cone_damage_modifier *= 1.0 + (value / 100.0)

		## CHARGE SHOT
		"charge_damage":
						player.charge_shot.damage_multiplier += value
		"charge_buildup":
			player.charge_shot.max_shots_for_charged = max(2, player.charge_shot.max_shots_for_charged - int(value))
		
		## Upgrades
		"companion_1_unlock":
			_unlock_companion("Companion1", player)
		"companion_1_level":
			_level_up_companion("Companion1", value, player)
		"companion_2_unlock":
			_unlock_companion("Companion2", player)
		"companion_2_level":
			_level_up_companion("Companion2", value, player)
	upgrade_selected.emit(upgrade)

## Helper function for companions
func _unlock_companion(group_name: String, player: PlayerCharacter) -> void:
	var companion := get_tree().get_first_node_in_group(group_name)
	if companion == null:
		push_error("UpgradeSystem: companion not found in group: ", group_name)
		return
	companion.visible = true
	companion.process_mode = Node.PROCESS_MODE_INHERIT
	print("Unlocked: ", group_name)


func _level_up_companion(group_name: String, value: float, player: PlayerCharacter) -> void:
	var companion := get_tree().get_first_node_in_group(group_name)
	if companion == null:
		push_error("UpgradeSystem: companion not found in group: ", group_name)
		return
	companion.level_up(value)

# Function to check if the upgrades can show
func is_upgrade_available(upgrade: UpgradeData, player: PlayerCharacter) -> bool:
	match upgrade.id:
		## Q Move unlocks
		"qmove_swap_aoe_pulse":
			return player.q_moves.ability_type == QMoves.AbilityType.Q_NONE
		"qmove_swap_cone":
			return player.q_moves.ability_type == QMoves.AbilityType.AOE_PULSE
		"qmove_aoe_damage", "qmove_aoe_duration":
			return player.q_moves.ability_type == QMoves.AbilityType.AOE_PULSE
		"qmove_cone_count", "qmove_cone_damage":
			return player.q_moves.ability_type == QMoves.AbilityType.DIRECTIONAL_CONE

		## Secondary unlocks
		"secondary_swap_dash":
			return not _has_upgrade("secondary_swap_dash")
		"secondary_swap_grenade":
			return not _has_upgrade("secondary_swap_grenade")

		## Secondaries
		"secondary_dash_force":
			return _is_secondary_equipped("secondary_swap_dash", player)
		"secondary_grenade_damage", "secondary_grenade_radius":
			return _is_secondary_equipped("secondary_swap_grenade", player)

		## Companions
		"companion_1_unlock":
			return not _has_upgrade("companion_1_unlock")
		"companion_2_unlock":
			return not _has_upgrade("companion_2_unlock")
		"companion_1_level":
			return _has_upgrade("companion_1_unlock")
		"companion_2_level":
			return _has_upgrade("companion_2_unlock")

	return true

func _is_secondary_equipped(upgrade_id: String, player: PlayerCharacter) -> bool:
	var secondary = player.get_node_or_null("SecondaryFire")
	if secondary == null:
		return false
	match upgrade_id:
		"secondary_swap_grenade":
			return secondary.secondary_actions.get("secondary_fire") == secondary._secondary_grenade
		"secondary_swap_dash":
			return secondary.secondary_actions.get("secondary_fire") == secondary._secondary_dash
	return false

func _has_upgrade(id: String) -> bool:
	## Returns true if the player has picked this upgrade at least once
	for u in all_upgrades:
		if u.id == id and u.current_level > 0:
			return true
	return false

# Reset used so that each upgrades would not carry over per stage
func reset() -> void:
	for upgrade in all_upgrades:
		upgrade.current_level = 0
