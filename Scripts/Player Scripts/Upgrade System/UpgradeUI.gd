class_name UpgradeUI
extends Control

@export var player: PlayerCharacter
@export var animator: CanvasLayer

@export var card_1: Button 
@export var card_2: Button 
@export var card_3: Button

@export var manager: GManager

var current_cards: Array[UpgradeData] = []


func show_upgrades(p: PlayerCharacter) -> void:
	player = p
	manager = p.manager
	current_cards = UpgradeSystemScript.get_random_cards(player)

	if current_cards.is_empty():
		_close()
		return

	_populate_card(card_1, current_cards[0] if current_cards.size() > 0 else null)
	_populate_card(card_2, current_cards[1] if current_cards.size() > 1 else null)
	_populate_card(card_3, current_cards[2] if current_cards.size() > 2 else null)

	visible = true
	manager._pauseGame()

	## Play popup animation
	if animator:
		print("Trying to play animation")
		animator.play_popup()
		animator.visible = true


func _populate_card(card: Button, upgrade: UpgradeData) -> void:
	if upgrade == null:
		card.visible = false
		return
	card.visible = true
	card.get_node("Name").text = upgrade.display_name
	card.get_node("Description").text = upgrade.get_description()
	card.get_node("Category").text = UpgradeData.UpgradeCategory.keys()[upgrade.category]
	card.get_node("Level").text = upgrade.get_level_label()
	
	var icon_node := card.get_node_or_null("Icon") as TextureRect
	if icon_node:
		icon_node.texture = upgrade.icon
		icon_node.visible = upgrade.icon != null


func _on_card_1_pressed() -> void:
	_pick(0)

func _on_card_2_pressed() -> void:
	_pick(1)

func _on_card_3_pressed() -> void:
	_pick(2)


@export var powerup_display: PowerUpDisplay


func _pick(index: int) -> void:
	if player == null:
		push_error("UpgradeUI: player is null in _pick")
		return
	if index >= current_cards.size():
		return
	if animator:
		await animator.play_dismiss(index)

	var chosen := current_cards[index]
	UpgradeSystemScript.apply_upgrade(chosen, player)

	## Add icon to HUD display
	if powerup_display:
		powerup_display.add_upgrade_icon(chosen)

	_close()


func _close() -> void:
	visible = false
	manager._resumeGame()
