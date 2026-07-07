class_name PowerUpDisplay
extends Control

## Max icons per row before wrapping to next row
@export var icons_per_row: int = 10
@export var icon_size: Vector2 = Vector2(32, 32)
@export var icon_spacing: Vector2 = Vector2(4, 4)
@export var icon_scene: PackedScene  ## optional — leave null to generate icons in code

## Fallback color per category if no icon texture
var category_colors := {
	UpgradeData.UpgradeCategory.STAT:           Color(0.4, 0.8, 0.4),
	UpgradeData.UpgradeCategory.SECONDARY_FIRE: Color(0.8, 0.6, 0.2),
	UpgradeData.UpgradeCategory.Q_MOVE:         Color(0.4, 0.6, 1.0),
	UpgradeData.UpgradeCategory.CHARGE_SHOT:    Color(1.0, 0.8, 0.2),
	UpgradeData.UpgradeCategory.AGIMAT:         Color(0.8, 0.3, 1.0),
}

## Tracks all displayed icons — key = upgrade id, value = Array of icon nodes
## (array because stacking upgrades like stat_damage can appear multiple times)
var icon_map: Dictionary = {}
var all_icons: Array = []  ## ordered list for layout recalculation

@onready var icon_container: Control = $IconContainer


func _ready() -> void:
	if icon_container == null:
		push_error("PowerupDisplay: IconContainer child node not found")


func add_upgrade_icon(upgrade: UpgradeData) -> void:
	var icon := _create_icon(upgrade)
	icon_container.add_child(icon)
	all_icons.append(icon)

	if not icon_map.has(upgrade.id):
		icon_map[upgrade.id] = []
	icon_map[upgrade.id].append(icon)

	_recalculate_layout()
	_animate_icon_in(icon)


func _create_icon(upgrade: UpgradeData) -> Control:
	var container := Panel.new()
	container.custom_minimum_size = icon_size
	container.size = icon_size

	## Background color tinted by category
	var style := StyleBoxFlat.new()
	style.bg_color = category_colors.get(upgrade.category, Color.GRAY)
	style.border_color = Color.WHITE
	style.set_border_width_all(1)
	style.set_corner_radius_all(3)
	container.add_theme_stylebox_override("panel", style)

	## Icon texture if available
	if upgrade.icon != null:
		var tex := TextureRect.new()
		tex.texture = upgrade.icon
		tex.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		tex.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		tex.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		tex.offset_left = 2
		tex.offset_top = 2
		tex.offset_right = -2
		tex.offset_bottom = -2
		container.add_child(tex)
	else:
		## Fallback — show first letter of upgrade name
		var label := Label.new()
		label.text = upgrade.display_name.left(1).to_upper()
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		label.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		label.add_theme_font_size_override("font_size", 10)
		container.add_child(label)

	## Tooltip on hover
	container.tooltip_text = "%s\n%s" % [upgrade.display_name, upgrade.get_description()]

	return container


func _recalculate_layout() -> void:
	for i in range(all_icons.size()):
		var row := i / icons_per_row
		var col := i % icons_per_row
		var icon : Control = all_icons[i]
		icon.position = Vector2(
			col * (icon_size.x + icon_spacing.x),
			row * (icon_size.y + icon_spacing.y)
		)

	## Resize container to fit all icons
	var rows := ceili(float(all_icons.size()) / icons_per_row)
	icon_container.custom_minimum_size = Vector2(
		icons_per_row * (icon_size.x + icon_spacing.x),
		rows * (icon_size.y + icon_spacing.y)
	)


func _animate_icon_in(icon: Control) -> void:
	icon.scale = Vector2.ZERO
	icon.pivot_offset = icon_size / 2.0
	var tween := create_tween()
	tween.tween_property(icon, "scale", Vector2(1.2, 1.2), 0.15)\
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(icon, "scale", Vector2(1.0, 1.0), 0.1)\
		.set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)


func clear_all() -> void:
	for icon in all_icons:
		if is_instance_valid(icon):
			icon.queue_free()
	all_icons.clear()
	icon_map.clear()
