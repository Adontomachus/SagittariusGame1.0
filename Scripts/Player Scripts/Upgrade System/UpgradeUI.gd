class_name UpgradeUI
extends Control

@export var player: PlayerCharacter
@export var animator: CanvasLayer

@onready var card_1: Button = $CanvasLayer/UpgradeText/Card1
@onready var card_2: Button = $CanvasLayer/UpgradeText/Card2
@onready var card_3: Button = $CanvasLayer/UpgradeText/Card3

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


func _on_card_1_pressed() -> void:
	_pick(0)

func _on_card_2_pressed() -> void:
	_pick(1)

func _on_card_3_pressed() -> void:
	_pick(2)


func _pick(index: int) -> void:
	if player == null:
		push_error("UpgradeUI: player is null in _pick")
		return
	if index >= current_cards.size():
		return

	if animator:
		await animator.play_dismiss(index)

	UpgradeSystemScript.apply_upgrade(current_cards[index], player)
	_close()


func _close() -> void:
	visible = false
	manager._resumeGame()
