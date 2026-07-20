class_name ChainTierPanel
extends Control

#@export var icon_rect: TextureRect
@export var tier_name_label: Label
@export var tier_desc_label: Label
@export var panel_container: Control  ## the sliding panel itself
@export var slide_in_x: float = 0   ## x position when fully visible
@export var slide_out_x: float = 2000  ## x position when hidden (off right edge)
@export var slide_duration: float = .5

## Tier data
var tier_data := {
	0: {
		"name": "",
		"desc": "",
		"color": Color.WHITE,
		"icon": null
	},
	4: {
		"name": "COMET FORM",
		"desc": "Projectiles are larger, faster, and hit harder.",
		"color": Color(1.0, 0.8, 0.4),
		"icon": null  ## assign via export or load path
	},
	8: {
		"name": "CADENCE MODE",
		"desc": "Charge shot fills from perfect hits. Double tempo.",
		"color": Color(0.5, 0.9, 1.0),
		"icon": null
	},
	16: {
		"name": "ECHO NOVA",
		"desc": "All nearby enemies are struck by a wave of sound.",
		"color": Color(1.0, 0.3, 0.9),
		"icon": null
	}
}

## Optional icon textures per tier — assign in inspector
@export var icon_comet: Texture2D
@export var icon_cadence: Texture2D
@export var icon_nova: Texture2D

var tween: Tween
var current_tier: int = 0
var is_visible_state: bool = false


func _ready() -> void:
	## Load icons into tier data
	tier_data[4]["icon"] = icon_comet
	tier_data[8]["icon"] = icon_cadence
	tier_data[16]["icon"] = icon_nova

	## Start hidden off screen
	if panel_container:
		panel_container.position.x = slide_out_x


func show_tier(tier: int) -> void:
	if tier == current_tier and is_visible_state:
		return

	current_tier = tier

	if tier == 0:
		_slide_out()
		return

	var data : Dictionary = tier_data.get(tier, tier_data[0])

	## Update content
	if tier_name_label:
		tier_name_label.text = data["name"]
		tier_name_label.modulate = data["color"]
	if tier_desc_label:
		tier_desc_label.text = data["desc"]
	#if icon_rect and data["icon"] != null:
		#icon_rect.texture = data["icon"]
		#icon_rect.visible = true
	#elif icon_rect:
		#icon_rect.visible = false

	_slide_in()


func _slide_in() -> void:
	is_visible_state = true
	if tween:
		tween.kill()
	tween = create_tween()
	tween.tween_property(panel_container, "position:x", slide_in_x, slide_duration)\
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


func _slide_out() -> void:
	is_visible_state = false
	if tween:
		tween.kill()
	tween = create_tween()
	tween.tween_property(panel_container, "position:x", slide_out_x, slide_duration)\
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)


func hide_panel() -> void:
	current_tier = 0
	_slide_out()
