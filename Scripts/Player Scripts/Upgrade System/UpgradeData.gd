class_name UpgradeData
extends Resource

enum UpgradeCategory { STAT, SECONDARY_FIRE, Q_MOVE, CHARGE_SHOT }

@export var id: String
@export var display_name: String
@export var category: UpgradeCategory
@export var max_level: int = 5

## Description shown on the card — use {value} as a placeholder for the next level's value
## e.g. "Increase damage by {value}%"
@export var description_template: String

## The value that scales per level — damage %, speed %, etc.
## Each entry is the value for that level (index 0 = level 1, etc.)
@export var values_per_level: Array[float] = []

var current_level: int = 0


func is_maxed() -> bool:
	return current_level >= max_level


func get_next_value() -> float:
	if current_level >= values_per_level.size():
		return values_per_level[-1]  # repeat last value if not enough entries
	return values_per_level[current_level]


func get_description() -> String:
	return description_template.replace("{value}", str(get_next_value()))


func get_level_label() -> String:
	if max_level == 1:
		return "Unique"
	return "Level %d / %d" % [current_level, max_level]
